#include <my_global.h>
#include <mysql.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <unistd.h>
#include "update.h"

#define RUN_AS_DAEMON 1 
#define SLEEP_MS(ms) (usleep(1000*ms))

const char pid_filename[] = "/web/html/trac/backend/logs/monitor.pid";
int lfp;

/* Handles interrupts. Deletes the pid when program is killed. */
void signal_handler(int sig)
{
    switch(sig)
    {
        case SIGHUP:
            syslog(LOG_INFO, "Daemon shutting down.");
            closelog();
            unlink(pid_filename);
            exit(EXIT_SUCCESS);
        case SIGINT:
            unlink(pid_filename);
            exit(EXIT_SUCCESS);
        case SIGTERM:
            unlink(pid_filename);
            exit(EXIT_SUCCESS);
        default:
            break;
    }
}

int main(void) {
        
        if (RUN_AS_DAEMON)
        {
            /* Our process ID and Session ID */
            pid_t pid, sid;
        
            /* Fork off the parent process */
            pid = fork();
            if (pid < 0) {
                exit(EXIT_FAILURE);
            }
            /* If we got a good PID, then
               we can exit the parent process. */
            if (pid > 0) {
                exit(EXIT_SUCCESS);
            }

            /* Change the file mode mask */
            umask(0);
                
            /* Open any logs here */        
            //openlog("/web/html/trac/backend/logs/monitor.log", LOG_PID|LOG_CONS,
            //        LOG_DAEMON);
                
            /* Create a new SID for the child process */
            sid = setsid();
            if (sid < 0) {
                /* Log the failure */
                exit(EXIT_FAILURE);
            }
        
            /* Change the current working directory */
            if ((chdir("/")) < 0) {
                /* Log the failure */
                exit(EXIT_FAILURE);
            }

            /* Set the lock file. */
            signal(SIGHUP, signal_handler);
            lfp = open(pid_filename, O_RDWR|O_CREAT, 0640);
            if (lfp < 0)
                exit(EXIT_FAILURE); // can't open
            if (lockf(lfp, F_TLOCK, 0) < 0)
                exit(EXIT_FAILURE); // can't lock
            char str[10];
            sprintf(str, "%d\n", getpid());
            write(lfp, str, strlen(str));
            close(lfp);
        
            /* Close out the standard file descriptors */
            close(STDIN_FILENO);
            close(STDOUT_FILENO);
            close(STDERR_FILENO);
        }

        /* Daemon-specific initialization goes here */
        
        // Connect to the database.
        MYSQL *con = mysql_init(NULL);
        if (con == NULL)
            exit(EXIT_FAILURE);

        if (!mysql_real_connect(con, hostname, username, password, database,0,NULL,0))
        {
            mysql_close(con);
            exit(EXIT_FAILURE);
        }
        syslog(LOG_INFO, "Daemon connected to MYSQL database.");
        
        /* The Big Loop */
        while (1) {
           /* Do some task here ... */
           if (handle_updates(con))
               exit(EXIT_FAILURE);
           
           SLEEP_MS(1000); /* wait */
        }
   closelog();
   mysql_library_end();
   exit(EXIT_SUCCESS);
}
