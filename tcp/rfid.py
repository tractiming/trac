import MySQLdb
import datetime
import time

HOST = "localhost"
DATABASE = "trac"
USER = "elliot"
PASSWORD = "mymysqlpassword"
TABLE = "demotable"

test_string = ("""Tag=E200 A9D0 SD8A S994  Disc=Fri Jun 18 12:58:18 PDT 2004"""
               """  Last=Fri Jun 18 12:58:18 PDT 2004  Ant=0  Count=3""")

test_string_2 = ("""Tag=E200 A9D0 SD8A S994  Disc=Fri Jun 18 12:58:18 PDT 2004"""
                 """  Last=Fri Jun 18 12:54:18 PDT 2004  Ant=0  Count=3""")

months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12}

class RFIDTag():
    """Empty class for storing tag info."""
    pass

def update_tag_info(tag, string):
    tokens = string.split('  ')
    for token in tokens:
        s = token.split('=')
        if s[0] == "Tag":
            tag.id = s[1]
        elif s[0] == "Last":
            t1 = s[1].split(' ')
            t2 = t1[3].split(':')
            tag.time = datetime.datetime(int(t1[5]), months[t1[1]],
                    int(t1[2]), int(t2[0]), int(t2[1]), int(t2[2]))

class Database():
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
    database.cursor.execute("SELECT * from %s WHERE TAG='%s'" %(TABLE, tag.id))
    if database.cursor.fetchall():
        return True
    else:
        return False

def register_tag(database, tag):
    """Add a tag to the table if it does not already exist."""
    database.connect()
    if not tag_in_database(database, tag): 
        database.cursor.execute(
                "INSERT INTO %s (TAG, TAGTIME, PACE) VALUES ('%s', '%s', %s)" 
                %(TABLE, tag.id, tag.time.strftime('%Y-%m-%d %H:%M:%S'), 0))
    database.disconnect()

def update_database_tags(database, tag):
    """Updates a tag's info in the database."""
    database.connect()
    database.cursor.execute("UPDATE %s SET TAGTIME='%s' WHERE TAG='%s'"
            %(database.table, tag.time.strftime('%Y-%m-%d %H:%M:%S'), tag.id))
    database.disconnect()

def print_table(database):
    """Prints all entries in the table."""
    database.connect()
    database.cursor.execute("SELECT * FROM demotable")
    rows = database.cursor.fetchall()
    for row in rows:
        for col in row:
            print '%s' %col,
        print '\n',    

def test_db_update():
    db = Database(HOST, DATABASE, USER, PASSWORD, TABLE)
    db.connect()
    tag = RFIDTag()
    update_tag_info(tag, test_string_2)
    register_tag(db, tag)
    update_database_tags(db, tag)
    print_table(db)

if __name__ == "__main__":
    test_db_update()




