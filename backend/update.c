#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "update.h"
#include "cJSON.h"

const char hostname[] = "localhost";
const char username[] = "elliot";
const char password[] = "millie";
const char database[] = "trac";

const char update_query[] = "SELECT * FROM readerData AS r "
                            "INNER JOIN sessionData AS s ON " 
                            "(r.readerID=s.R1 OR r.readerID=s.R2 OR r.readerID=s.R3 "
                            "OR r.readerID=s.R4 OR r.readerID=s.R5) "
                            "INNER JOIN userData AS u ON r.tagID=u.tag_id1 "
                            "WHERE r.parsed=0";
const char session_query[] = "SELECT workoutID from splitData WHERE new=1 "
                             "GROUP BY workoutID";
char g_query[200];

/* Checks for newly read tags and passes info to workout table. */
int process_new_split_data(MYSQL *con)
{
    MYSQL_RES *res;
    MYSQL_ROW row;

    // Pass through raw data table looking for newly added tags.
    if (mysql_query(con, update_query))
    	return ERROR;    // query failed

    res = mysql_store_result(con);
    if (res == NULL)
        return SUCCESS;    // no new entries, return success

    // Loop through updated entries (if any).
    while ((row = mysql_fetch_row(res)))
    {
	// For each match, insert a new entry into the splitData table.
        sprintf(g_query, "INSERT IGNORE INTO splitData "
                         "(name, workoutID, time, tagID, new) "
                         "VALUES (\"%s\", %s, \"%s\", \"%s\", %i)", 
                row[12], row[4], row[1], row[16], 1);
        
        if (mysql_query(con, g_query))
        {
            mysql_free_result(res);
    	    return ERROR;    // query failed
        }

        // Finally, unset the parsed flag in the raw data table.
        sprintf(g_query, "UPDATE readerData SET parsed=1 WHERE tagID=\"%s\"", row[0]);
        if (mysql_query(con, g_query)) 
        {
            mysql_free_result(res);
            return ERROR;	     
        }

    }
    mysql_free_result(res);
    return SUCCESS;
}

/* Stores all the new session id ints in an array. */
int get_new_session_ids(MYSQL *con, int **w_id, int *n)
{
    int k=0;
    MYSQL_RES *res;
    MYSQL_ROW row;

    // Pass through raw data table looking for newly added tags.
    if (mysql_query(con, session_query))
    	return ERROR;    // query failed

    res = mysql_store_result(con);
    if (res == NULL)
    {
        *n = 0; // no new tags to be processed
        return SUCCESS;  
    }  

    // Get an array of all the new workout ids.
    int temp = mysql_num_rows(res); *n = temp;
    *w_id = malloc(temp*sizeof(int));
    if (*w_id == NULL)
    {
        mysql_free_result(res);
        return ERROR;
    }
    k = 0; 
    while ((row = mysql_fetch_row(res)))
    {
        (*w_id)[k] = atoi(row[0]);
        k++;
    }

    mysql_free_result(res);
    return SUCCESS;
}

/* Adds the unique integer identifier for each runner in the session. */
int get_tags_in_session(MYSQL *con, int s_id, int **tag_ints, char ***names, int *n)
{
    int k=0;
    MYSQL_RES *res;
    MYSQL_ROW row;

    // Get all the tag ids of where the session matches the one given.
    sprintf(g_query, "SELECT tagID, name FROM splitData WHERE workoutID=%i "
                     "GROUP BY tagID", s_id);
    if (mysql_query(con, g_query))
    	return ERROR;    // query failed

    res = mysql_store_result(con);
    if (res == NULL)
        return 0;    

    // Get an array of all the tag ints.
    int temp = mysql_num_rows(res); *n = temp;
    *tag_ints = malloc(temp*sizeof(int));
    if (*tag_ints == NULL)
    {
        mysql_free_result(res);
        return ERROR;
    }

    // Allocate the array for names.
    *names = malloc(temp*sizeof(char *));
    for (k=0; k<temp; k++)
        (*names)[k] = malloc(20*sizeof(char));
    k = 0; 
    while ((row = mysql_fetch_row(res)))
    {
        (*tag_ints)[k] = atoi(row[0]);
        strcpy((*names)[k], row[1]);
        k++;
    }
    mysql_free_result(res);
    return SUCCESS;

}


/* Fills the array of splits for a given runner in a given session. */
int get_splits_from_id(MYSQL *con, int s_id, int t_id, float **splits, int **cnt, int *n)
{
    int k=0;
    MYSQL_RES *res;
    MYSQL_ROW row;

    // Get all time differences for the runner.
    sprintf(g_query, "SELECT (TIMESTAMPDIFF(SECOND, (SELECT MIN(time) FROM splitData "
                     "WHERE (workoutID=%i AND tagID=%i)), time)) as dt FROM splitData "
                     "WHERE (workoutID=%i AND tagID=%i) ORDER BY dt ASC", 
                     s_id, t_id, s_id, t_id);
    if (mysql_query(con, g_query))
    	return ERROR;    // query failed

    res = mysql_store_result(con);
    if (res == NULL)
        return 0;    

    // Get an array of all the tag ints.
    int temp = mysql_num_rows(res); *n = temp;
    *splits = malloc(temp*sizeof(float));
    if (*splits == NULL)
    {
        mysql_free_result(res);
        return ERROR;
    }
    *cnt = malloc(temp*sizeof(int));
    if (*cnt == NULL)
    {
        mysql_free_result(res);
        return ERROR;
    }

    k = 0; 
    while ((row = mysql_fetch_row(res)))
    {
        (*splits)[k] = atof(row[0]);
        (*cnt)[k] = k;
        //printf("test %i\n", (*splits)[k]);
        k++;
    }
    mysql_free_result(res);
    return SUCCESS;

}

/* Stores the date string in month.day.year format. */
int get_date_string(char *time_s)
{
    struct tm *current_time;
    time_t timenow;
    int month, day, year;

    time(&timenow);
    current_time = localtime(&timenow);
    month = current_time->tm_mon+1;
    day = current_time->tm_mday;
    year = current_time->tm_year+1900;
    sprintf(time_s, "%i.%i.%i", month, day, year);

    return SUCCESS;
}

/* Updates all the json split files where new data has been found. */
int write_json_splits(MYSQL *con)
{
    int ns, *w_id;
    int nr, *t_id;
    int ni, *cntr;
    char **name_list;
    float *splits;
    int k, j, m;
    cJSON *root, *rnr, *rnr_a;
    const char *json_string;
    char date[15];
    FILE *fp;
    char filename[50];

    // Get the ids of any session where a tag has been added.
    if (get_new_session_ids(con, &w_id, &ns))
    {
        free(w_id);
        return ERROR;
    }

    // For each session, update the split file.
    for (k=0; k<ns; k++)
    {
        // Immediately clear the new flag for all tags in an active session.
        // Note: new can only be set by the process_new_split_data() method, so it is not 
        // possible for a new tag to have been added since the list was made.
        sprintf(g_query, "UPDATE splitData SET new=0 WHERE workoutID=%i", w_id[k]);
        if (mysql_query(con, g_query))
    	    return ERROR;    // query failed

        // Create a new cJSON object.
        root = cJSON_CreateObject();
        get_date_string(date); 
        cJSON_AddStringToObject(root, "date", date);
        cJSON_AddItemToObject(root, "workoutID", cJSON_CreateNumber((double)w_id[k]));
	cJSON_AddItemToObject(root, "runners", rnr_a = cJSON_CreateArray());

        // First get the list of all tags entered into the workout.
        //printf("For workout %i:\n", w_id[k]);
        if (get_tags_in_session(con, w_id[k], &t_id, &name_list, &nr))
        {
            free(w_id); free(t_id); cJSON_Delete(root);
            return ERROR;
        }

        // For each tag, get the splits and write to json object.
        for (j=0; j<nr; j++)
        {   
	    // Add runner to json.
            cJSON_AddItemToArray(rnr_a, rnr = cJSON_CreateObject());
            cJSON_AddStringToObject(rnr, "name", name_list[j]);

            // Get all of the splits for this runner.
            if (get_splits_from_id(con, w_id[k], t_id[j], &splits, &cntr, &ni))
            {
                free(w_id); free(t_id); free(splits); free(cntr); cJSON_Delete(root);
                return ERROR;
            }

            // Add splits and counter to json.
	    cJSON_AddItemToObject(rnr, "counter",  cJSON_CreateIntArray(cntr, ni));
 	    cJSON_AddItemToObject(rnr, "interval", cJSON_CreateFloatArray(splits, ni) );

            // Free the memory for splits and counter.
            free(splits);            
            free(cntr);
        }
        
        // Print the json string to an appropriate file.
        // Note: use absolute path since daemon runs in root dir.
        sprintf(filename, "/web/html/trac/splits/w%i.json", w_id[k]); 
        fp = fopen(filename, "w");
        if (fp != NULL)
        {
            json_string = cJSON_Print(root);
            fputs(json_string, fp);
            fclose(fp);
        }
        cJSON_Delete(root);

        // Free memory for tag list, name list.
        free(t_id);
        for (m=0;m<nr;m++) free(name_list[m]); free(name_list);
    }

    free(w_id);
    return SUCCESS;
}

/* Handles one update cycle - update tables and split files. */
int handle_updates(MYSQL *con)
{
    if (process_new_split_data(con))
        return ERROR;
    if (write_json_splits(con))
        return ERROR;
    //if (process_new_split_data(con) || write_json_splits(con))
    //    return ERROR;

    return SUCCESS;
}


/*int main(void)
{
    // Connect to the MYSQL database.
    MYSQL *con = mysql_init(NULL);
    if (con == NULL)
        exit(EXIT_FAILURE);

    if (mysql_real_connect(con, hostname, username, password, database, 0, NULL, 0)
         == NULL)
    {
        mysql_close(con);
        exit(EXIT_FAILURE);
    }
    if(write_json_splits(con))
    {
        mysql_close(con);
        exit(EXIT_FAILURE);
    }
        //printf("n is %d\n", n);
        //int k;
        //for (k=0; k<2; k++)
        //    printf("%i\n", w_id[k]);
        //if (process_new_split_data(con))
        //{
        //    mysql_close(con);
        //    exit(EXIT_FAILURE);
        //}
    

    return 0;
}*/
