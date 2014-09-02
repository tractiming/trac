import sys
import signal
import datetime

# All Twisted imports.
from twisted.internet.protocol import Factory, Protocol
from twisted.protocols.basic import LineReceiver
from twisted.internet import reactor, defer, threads
from twisted.python import log
from twisted.application.internet import TCPServer
from twisted.application.service import Application

# Set up the Django environment.
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "tracd.settings")
from update.models import Split, Tag, Reader
from django.core.exceptions import ObjectDoesNotExist

#######################################################################################
# Django Split updates.
#######################################################################################

def parse_msg(string):
    """Extracts split data from reader notification message."""
    # Check that tag contains good information.
    if ('Tag:' not in string) or ('Last:' not in string) or ('Ant:' not in string):
        return None

    msg_info = {}
    for d in string.split(', '):
        k = d.split(':')
        
        if k[0] == 'Tag':
            msg_info['name'] = k[1]
        elif k[0] == 'Last':
            time_str = d[5:]
            msg_info['time'] = datetime.datetime.strptime(time_str, "%Y/%d/%m %H:%M:%S.%f") 
        elif k[0] == 'Ant':
            msg_info['Ant'] = int(k[1])
    msg_info['rdr'] = 1
    return msg_info

def update_split(*args, **kwargs):
    data = kwargs.pop('data')
    s_time = data['time']

    # If the tag or reader is not registered, ignore data.
    try:
        t = Tag.objects.get(id_str=data['name'])
        r = Reader.objects.get(num=data['rdr']) 
    except ObjectDoesNotExist:
        return
   
    # Get workout. Ignore tag if it does not belong to a workout.
    w = r.workouts.filter(start_time__lt=s_time, stop_time__gt=s_time)
    if not w:
        return

    s = Split.objects.create(tag_id=t.pk, time=s_time, reader_id=r.pk, workout_id=w[0].pk)
   
def split_add_success(split):
    pass 


#######################################################################################
# Twisted TCP server.
#######################################################################################

# Timeout (in seconds) for dropped tcp connections.
TIMEOUT = 300

# TCP port.
PORT = 36740

class ReaderComm(LineReceiver):

    def __init__(self):
        signal.signal(signal.SIGALRM, self.alarm_handler)

    def alarm_handler(self, signum, frame):
        """Handles timeouts from dropped tcp connections."""
        log.msg("Connection timeout.")
        self.transport.loseConnection()
 
    def lineReceived(self, line):
        signal.alarm(TIMEOUT)
        data = parse_msg(line)
        if data:
            d = threads.deferToThread(update_split, data=data)
            d.addCallback(split_add_success)
	    log.msg("Tag read: "+str(data))
        else:
	    log.msg("Bad data received")
                
    def connectionMade(self):
        log.msg("Connection made!")
        signal.alarm(TIMEOUT)

    def connectionLost(self, reason):
        log.msg("Connection lost!"+ str(reason))

# Define the application. (Needed to run via twistd.)
factory = Factory()
factory.protocol = ReaderComm
application = Application("tcp_server")
tcpServerService = TCPServer(PORT, factory)
tcpServerService.setServiceParent(application)


test_string_4 = "Tag:11C4 00E3 2A39, Disc:1970/03/11 16:06:33.285, Last:1970/03/11 16:17:33.285, Count:1, Ant:0, Proto:2"

