#include <my_global.h>
#include <mysql.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <unistd.h>
#include "update.h"

#define RUN_AS_DAEMON 1 
#define SLEEP_MS(ms) (usleep(1000*ms))

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
            //openlog("traclog", LOG_PID, LOG_DAEMON);
                
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

        if (mysql_real_connect(con, hostname, username, password, database,0,NULL,0)==NULL)
        {
            mysql_close(con);
            exit(EXIT_FAILURE);
        }

        
        /* The Big Loop */
        while (1) {
           /* Do some task here ... */
           if (handle_updates(con))
               exit(EXIT_FAILURE);
           
           SLEEP_MS(1000); /* wait */
        }
   exit(EXIT_SUCCESS);
}
