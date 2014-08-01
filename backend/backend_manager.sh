#!/bin/bash

start_monitor ()
{
  # Start the monitor daemon.
  monitor/trac_monitor
}

stop_monitor ()
{
  # Kill the monitor daemon from PID file.
  if [ -f logs/monitor.pid ]; then  
    kill -1 $(cat logs/monitor.pid)
  fi
}

start_tcp ()
{
  # Start the tcp server.
  twistd -l logs/tcp_server.log --pidfile logs/tcp_server.pid -y tcp/twisted_server.py
}

stop_tcp ()
{
  # Kill the tcp server daemon.
  if [ -f logs/tcp_server.pid ]; then
    kill $(cat logs/tcp_server.pid)
  fi
}

while getopts udsr name
do
  case $name in
    u)uopt=1;;
    d)dopt=1;;
    s)sopt=1;;
    r)ropt=1;;
    *)echo "Invalid argument"
  esac
done

if [[ ! -z $sopt ]]
then 
  if [ -f logs/monitor.pid ]
  then  
    echo "Monitor daemon is running."
  else
    echo "Monitor daemon is not running."
  fi

  if [ -f logs/tcp_server.pid ]
  then
    echo "TCP listener is running."
  else
    echo "TCP listener is not running."
  fi
fi

if [[ ! -z $uopt ]]
then
  start_monitor
  start_tcp
  echo "TRAC server started."
fi

if [[ ! -z $dopt ]]
then 
  stop_tcp
  stop_monitor
  echo "TRAC server stopped."
fi

if [[ ! -z $ropt ]]
then 
  stop_tcp
  stop_monitor
  echo "TRAC server stopped."
  start_monitor
  start_tcp
  echo "TRAC server started."
fi







