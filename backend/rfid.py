import MySQLdb
import datetime
import time
import math

# Parameters for connecting to mysql db on localhost. 
#TODO: find a more secure way of handling password.
DB_PARAMS = {
    "host" : "localhost",
    "database" : "trac",
    "user" : "elliot",
    "password" : "millie",
    "table" : "readerData",
}

# Utility dict to convert month strings to ints.
months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12}

# The following class and functions store info into tag objects.
class RFIDTag:
    """Empty class for storing tag info."""
    pass

def update_tag_info(tag, string):
    tokens = string.split(', ')
    for token in tokens:
        s = token.split(':')
        if s[0] == "Tag":
            tag.id = s[1]
        elif s[0] == "Last":
            hours = int((s[1].split(' '))[-1])
            minutes = int(s[2])
            sec_float = float(s[3])
            seconds = int(sec_float)
            microseconds = int((sec_float-seconds)*1000000)
            t4 = (s[1].split(' '))[0].split('/')
            tag.time = datetime.datetime(int(t4[0]), int(t4[1]), int(t4[2]),
                                         hours, minutes, seconds, microseconds)
        elif s[0] == "Ant":
            tag.ant = int(s[1])

def update_tag_info_old(tag, string):
    """Parses a message from reader and adds info to Tag object."""
    data_lines = string.split('\n')
    for line in data_lines:
        if 'Tag:' in line:
            tokens = line.split(', ')
    for token in tokens:
        s = token.split(':')
        if s[0] == "Tag":
            tag.id = s[1]
        elif s[0] == "Last":
            hours = int((s[1].split(' '))[-1])
            minutes = int(s[2])
            sec_float = float(s[3])
            seconds = int(sec_float)
            microseconds = int((sec_float-seconds)*1000000)
            t4 = (s[1].split(' '))[0].split('/')
            tag.time = datetime.datetime(int(t4[0]), int(t4[1]), int(t4[2]),
                                         hours, minutes, seconds, microseconds)
        elif s[0] == "Ant":
            tag.ant = int(s[1])

def print_tag_info(tag):
    """Print the information currently stored in the Tag object."""
    info = ""
    attributes = ['id', 'time', 'ant']
    for a in attributes:
        if hasattr(tag, a):
            info += "%s=%s, " %(a,str(getattr(tag, a)))
    info = '<RFID Tag: '+info[:-2]+'>'        
    return info
    #print info

# The following class and functions manage the interaction with the mysql db.
class Database:
    """A mysql database."""
    def __init__(self, host, database, user, password, table):
        self.host = host
        self.database = database
        self.user = user
        self.password = password
        self.table = table
        self.db = None
        self.cursor = None
        self.connected = False

    def connect(self):    
        """Connect to database. Sets database and cursor."""
        if not self.connected:
            self.db = MySQLdb.connect(host=self.host, user=self.user,
                                      passwd=self.password, db=self.database)
            self.cursor = self.db.cursor()
        if self.db:    
            self.connected = True
        
    def disconnect(self):
        """Disconect from database and commit any changes."""
        if self.connected:
            self.cursor.close()
            self.db.commit()
            self.db.close()
            self.db = None
            self.cursor = None
            self.connected = False

    def __repr__(self):
        return ("<DATABASE %s -- Host: %s, User: %s, Table:%s, Conn=%s>"
                %(self.database, self.host, self.user, self.table,
                    self.connected))

def tag_in_database(database, tag):
    """
    Returns True if the tag is already listed in the database, False
    otherwise.
    """
    if not tag.id:
        return False
    database.connect()
    database.cursor.execute("SELECT * from %s WHERE tagID='%s'"
        %(database.table, tag.id))
    if database.cursor.fetchall():
        return True
    else:
        return False

def register_tag(database, tag):
    """Add a tag to the table if it does not already exist."""
    database.connect()
    if not tag_in_database(database, tag): 
        database.cursor.execute(
                "INSERT INTO %s (tagID, tagTime) VALUES ('%s', '%s')" 
                %(database.table, tag.id, tag.time.strftime('%Y-%m-%d %H:%M:%S')))
    database.disconnect()

def remove_tag(database, tag):
    """Removes a tag from the table of tag data"""
    database.connect()
    if tag_in_database(database, tag):
	database.cursor.execute(
            "DELETE FROM %s WHERE tagID=%s LIMIT 1" %(database.table, tag.id))
    database.disconnect()

def update_database_tags(database, tag):
    """Updates a tag's info in the database."""
    database.connect()
    database.cursor.execute("INSERT INTO %s (tagID, tagTime, readerID, parsed) "
                            "VALUES ('%s', '%s', '%s', %i) ON DUPLICATE KEY UPDATE "
                            "tagTime = values (tagTime), readerID = values (readerID), "
                            "parsed = values (parsed)"
            %(database.table, tag.id, tag.time.strftime('%Y-%m-%d %H:%M:%S'), '1', 0))
    database.disconnect()

def handle_msg(db, tag, msg):
    """Updates tag info in database."""
    if (("beat" in msg) or ("Tag:" not in msg)):
        return 1

    update_tag_info(tag, msg)
    print print_tag_info(tag)
    update_database_tags(db, tag)
    return 0

def print_table(database, table=None):
    """Prints all entries in the table."""
    if table is None:
	table = database.table
    database.connect()
    database.cursor.execute("SELECT * FROM %s" %table)
    rows = database.cursor.fetchall()
    for row in rows:
        for col in row:
            print '%s' %col,
        print '\n',    

# The following is a set of tests for the tag reading and database updates.
# First there are a couple of strings that mimic the input coming from the reader.
test_string = ("""Tag=E200 A9D0 SD8A S994  Disc=Fri Jun 18 12:58:18 PDT 2004"""
               """  Last=Fri Jun 18 12:58:18 PDT 2004  Ant=0  Count=3""")

test_string_2 = ("""Tag=E200 A9D0 SD8A S994  Disc=Fri Jun 18 12:58:18 PDT 2004"""
                 """  Last=Fri Jun 18 12:54:18 PDT 2004  Ant=0  Count=3""")

test_string_3 = ("""
#Alien RFID Reader Auto Notification Message
#ReaderName: Alien RFID Reader
#ReaderType: Alien RFID Tag Reader, Model: ALR-9900+ (Four Antenna / Gen 2 / 902-928 MHz)
#IPAddress: 192.168.1.100
#CommandPort: 23
#MACAddress: 00:1B:5F:00:A2:20
#Time: 1970/03/11 16:06:33.338
#Reason: TAGS ADDED
#StartTriggerLines: 0
#StopTriggerLines: 0
Tag:11C4 00E3 2A39, Disc:1970/03/11 16:06:33.285, Last:1970/03/11 16:17:33.285, Count:1, Ant:0, Proto:2
#End of Notification Message""")

# Then some functions for reading from and writing to the database.
def test_full_msg_read():
    """Tests the parsing and reading functions (No database)."""
    tag = RFIDTag()
    update_tag_info(tag, test_string_3)
    print "Read the tag information:\n\t",
    print_tag_info(tag)

def test_full_msg_add():
    """Tests parsing, reading, and database functions."""  
    print "Testing database connection...",
    db = Database(**DB_PARAMS)
    db.connect()
    print "Connected!"

    print "Updating tag info...",
    tag = RFIDTag()
    update_tag_info(tag, test_string_3)
    register_tag(db, tag)
    update_database_tags(db, tag)
    print "Updated!"

    print "The following info exists in the database:"
    print_table(db)
    print "Test completed!"

if __name__ == "__main__":
    #test_full_msg_read()
    test_full_msg_add()




