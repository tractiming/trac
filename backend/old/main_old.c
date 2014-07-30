#include <my_global.h>
#include <mysql.h>

const char hostname[] = "localhost";
const char username[] = "elliot";
const char password[] = "millie";
const char database[] = "trac";

const char new_tag_query[] = "SELECT * FROM readerData WHERE parsed=0";
const char active_session_query[] = "SELECT sessionID FROM sessionData WHERE (startTime IS NOT NULL and stopTime IS NULL)";

char g_query[200];
char reader_name[20];
char session_name[20];

void error_and_exit(MYSQL *con)
{
    printf("%s\n", mysql_error(con));
    mysql_close(con);
    exit(1);
}

int main(void)
{
    // Connect to the MYSQL database.
    MYSQL *con = mysql_init(NULL);
    if (con == NULL)
        exit(1);

    if (mysql_real_connect(con, hostname, username, password, database, 0, NULL, 0) == NULL)
        error_and_exit(con);
    
    // Loop while checking for new data added to db.
    while(1)
    {
        if (mysql_query(con, new_tag_query))
            error_and_exit(con);

	MYSQL_RES *result = mysql_store_result(con);
        if (result == NULL)
            error_and_exit(con);

        // Loop through updated entries (if any).
	MYSQL_ROW row;
	while (row = mysql_fetch_row(result))
	{
            // Get the current session name.
            sprintf(reader_name, "%s", row[2]);
            sprintf(g_query, "SELECT * FROM sessionData WHERE (R1=%s OR R2=%s OR R3=%s OR R4=%s OR R5=%s) AND (startTime IS NOT NULL AND stopTime IS NULL) LIMIT 1", reader_name, reader_name, reader_name, reader_name, reader_name);

            if (mysql_query(con, g_query))
                error_and_exit(con);

            MYSQL_RES *result2 = mysql_store_result(con);

            if (result2 == NULL)
                error_and_exit(con);

	    MYSQL_ROW row2 = mysql_fetch_row(result2);
            sprintf(session_name, "s%s", row2[0]);
	    printf("%s\n", session_name); 
	    // If no current session found, handle this later.

            // Insert the new tag data into the session table. (Set new flag.)
            sprintf(g_query, "INSERT INTO %s ")


            // Finally, set the parsed flag in the raw data table.
            sprintf(g_query, "UPDATE readerData set parsed=1 where tagID=\'%s\'", row[0]);
            if (mysql_query(con, g_query))
                error_and_exit(con);	     
	}
    }

    /*
    // Loop through all active sessions.
    if (mysql_query(con, active_session_query))
        error_and_exit(con);

    */
    return 0;
}
