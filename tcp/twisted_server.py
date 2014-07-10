import sys
from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from twisted.python import log
import rfid

# TCP port.
PORT = 36740

# If DEBUG is set to True, simply echo out any incoming data, but do not process it.
DEBUG = False
if DEBUG:
    bug_msg = "ON"
else:
    bug_msg = "OFF"

class ReaderComm(Protocol):

    reader_id = None
    tag = rfid.RFIDTag()
    db = rfid.Database(**rfid.DB_PARAMS)

    def dataReceived(self, data):
        if DEBUG:
            log.msg(data)
        else:
	    try:
                # Ignore heartbeat messages.
                if "beat" not in data:
                    rfid.handle_tag(self.db, self.tag, data)
		    log.msg("Tag read:"+ rfid.print_tag_info(self.tag))
	    except:
	        log.msg("Error interpreting tag data.")

    def connectionMade(self):
        log.msg("Connection made!")

    def connectionLost(self, reason):
        log.msg("Connection lost!"+ str(reason))

def main():
    """Creates factory and listens for incoming connections."""
    # Log all output to standard output. TODO: log to appropriate file.    
    log.startLogging(sys.stdout)
    factory = Factory()
    factory.protocol = ReaderComm

    reactor.listenTCP(PORT, factory)
    reactor.run()


if __name__ == "__main__":
    print "Server started! (DEBUG is %s)" %(bug_msg)
    main()
        
