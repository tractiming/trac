import serial
import time
import socket
import sys

TCP_IP = '76.12.155.219' 
TCP_PORT = 36740
BUFFER_SIZE = 1024


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

def main():

    s = init_tcp()
    s.send("hello\r\n")
    sys.exit(0)

if __name__ == "__main__":
    main()
