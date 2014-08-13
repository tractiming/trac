import serial
import time
import socket
import sys
import MySQLdb

TCP_IP = '76.12.155.219' 
TCP_PORT = 36740
BUFFER_SIZE = 1024

DB_PARAMS = {
    "host" : "localhost",
    "database" : "trac",
    "user" : "elliot",
    "password" : "millie",
    "table" : "readerData",
}

def db_connect():    
    """Connect to database. Sets database and cursor."""
    db = MySQLdb.connect(host=DB_PARAMS["host"], user=DB_PARAMS["user"],
                              passwd=DB_PARAMS["password"], db=DB_PARAMS["database"])
    cursor = db.cursor()
    return db, cursor
    
def db_disconnect(db, cursor):
    """Disconect from database and commit any changes."""
    cursor.close()
    db.commit()
    db.close()

class Runner():
    def __init__(self, fname, lname, tag_id):
        self.fname = fname
        self.lname = lname
        self.tag_id = tag_id
        self.username = fname

def init_workout(db, cursor, w_num, runners, reader)
    """Initializes a workout in the database."""
    # Connect to the database.
    db, cursor = db_connect()

    # Add the runners to the user table.
    for r in runners:
        cursor.execute("INSERT IGNORE INTO userData (first_name, last_name, username, tag_id1) "
                       "VALUES (\"%s\", \"%s\", \"%s\", \"%s\")" 
                       %(r.fname, r.lname, r.username, r.tag_id))

    # Add the workout to the session table. Note: this only uses one reader
    # per workout.
    cursor.execute("INSERT IGNORE INTO sessionData (sessionID, R1) VALUES "
                   "(%i, %i)" %w_num)

    # Start the workout active by setting the start time to now.
    cursor.execute("UPDATE sessionData SET startTime=NOW() WHERE sessionID=%i"
            %w_num)

def del_workout(db, cursor, w_num):
    """Deletes a workout after the test has been run."""

def build_msg(tag):
    """Creates a string that emulates a reader notification."""
    pass

def init_tcp():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((TCP_IP, TCP_PORT))
    return s

def pass_msg(ser, soc):
    while True:
        msg = read_serial(ser)
        if msg:
            if soc is None:
                print msg,
            else:
                soc.send(msg)

def test_msg_send(tags, delay):
    """
    Tests sending random tag information. The frequency of the messages is
    determined by the delay argument.
    """
    # Get a random workout and add the tags to that workout.

def main():

    # Initialize the test data.
    runners = [
            Runner("Galen", "Rupp", "1111 2222"),
            Runner("Mo", "Farah", "1111 3333")
            ]
    s = init_tcp()
    s.send("hello\r\n")
    sys.exit(0)

if __name__ == "__main__":
    main()
