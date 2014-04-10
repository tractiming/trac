import sys
from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
import rfid

PORT = 36740

class ReaderComm(Protocol):

    reader_id = None
    tag = rfid.RFIDTag()
    db = rfid.Database(rfid.HOST, rfid.DATABASE, rfid.USER, 
                       rfid.PASSWORD, rfid.TABLE)

    def dataReceived(self, data):
        print data

    def lineReceived(self, data):
        pass

    def connectionMade(self):
        print "Connection made!"

def main():
    factory = Factory()
    factory.protocol = ReaderComm

    reactor.listenTCP(PORT, factory)
    reactor.run()


if __name__ == "__main__":
    print "Server started!"
    main()
        
