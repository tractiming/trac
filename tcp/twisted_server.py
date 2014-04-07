import sys
from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

PORT = 36740

class ReaderComm(Protocol):

    def dataReceived(self, data):
        print data

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
        
