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


months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12}

class RFIDTag():
    def __init__(self):
        self.id = None
        self.time = None

    def update(self, string):
        tokens = string.split('  ')
        for token in tokens:
            s = token.split('=')
            if s[0] == "Tag":
                self.id = s[1]
            elif s[0] == "Last":
                t1 = s[1].split(' ')
                t2 = t1[3].split(':')
                self.time = datetime.datetime(int(t1[5]), months[t1[1]],
                        int(t1[2]), int(t2[0]), int(t2[1]), int(t2[2]))

    def __repr__(self):
        return "<TAG -- ID: %s, Last: %s>" %(self.id, self.time)



def db_connect():
    """Return cursor to mysql database."""
    db = MySQLdb.connect(host=HOST, user=USER, passwd=PASSWORD, db=DATABASE)
    return db.cursor()

def update_tag_db(cur, tag):

    cur.execute("UPDATE  WHERE")

def register_tag(cur, tag):
    cur.execute("INSERT INTO %s (TAG, TAGTIME, PACE) VALUES ('%s', '%s', %s)" 
            %(TABLE, tag.id, tag.time.strftime('%Y-%m-%d %H:%M:%S'), 0))

if __name__ == "__main__":
    c = db_connect()
    tag = RFIDTag()
    tag.update(test_string)
    c.execute("SELECT * FROM demotable")
    rows = c.fetchall()
    for row in rows:
        for col in row:
            print '%s,' %col
        print '\n'    
    #register_tag(c, tag)
    #print tag 
