#ifndef UPDATE_H
#define UPDATE_H

#include <my_global.h>
#include <mysql.h>

#define SUCCESS 0
#define ERROR 1

extern const char hostname[];
extern const char username[];
extern const char password[];
extern const char database[];

int process_new_split_data(MYSQL *con);
int write_json_splits(MYSQL *con);
int handle_updates(MYSQL *con);

#endif
