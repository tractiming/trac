# This file makes the computer act as a passthrough between reader and server.

import serial
import time
import socket
import sys

TCP_IP = '76.12.155.219' 
TCP_PORT = 36740
BUFFER_SIZE = 1024

device = "/dev/ttyUSB0"

def read_serial(ser):
    out = ''
    while ser.inWaiting() > 0:
        out += ser.read(1)
    return out    

def init_serial():
    ser = serial.Serial(port=device, 
                        baudrate=115200, 
                        parity=serial.PARITY_NONE,
                        stopbits=serial.STOPBITS_ONE, 
                        bytesize=serial.EIGHTBITS)

    ser.open()

    while (not ser.isOpen()):
        pass

    ser.flushInput()
    ser.flushOutput()

    return ser

def init_tcp():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((TCP_IP, TCP_PORT))
    return s

def init_reader(ser):
    time.sleep(1)
    ser.write("PersistTime=2\r\n");
    time.sleep(0.5)
    ser.write("AutoModeReset\r\n");
    time.sleep(0.5)
    ser.write("AutoAction = Acquire\r\n");
    time.sleep(0.5)
    ser.write("AutoStartTrigger = 0,0\r\n");
    time.sleep(0.5)
    ser.write("AutoStopTimer = 0\r\n");
    time.sleep(0.5)
    ser.write("NotifyAddress = serial\r\n");
    time.sleep(0.5)
    ser.write("NotifyTrigger = Add\r\n");
    time.sleep(0.5)
    ser.write("NotifyMode = On\r\n");
    time.sleep(0.5)
    ser.write("AutoMode = On\r\n");
    time.sleep(0.5)
    time.sleep(2)

def pass_msg(ser, soc):
    while True:
        msg = read_serial(ser)
        if msg:
            if soc is None:
                print msg,
            else:
                soc.send(msg)

def main():
    if '--local' in sys.argv:
        loc = True
    else:
        loc = False

    ser = init_serial()
    print "Opened serial connection."
    init_reader(ser)
    print "Initialized RFID reader."
    if not loc:
        s = init_tcp()
    else:
        s = None
    print "Established TCP connection."
    print "Waiting for tag notifications..."
    try:
        pass_msg(ser, s)
    except KeyboardInterrupt:
        if not loc:
            s.close()
        print "Connection closed."
        sys.exit(0)

if __name__ == "__main__":
    main()
