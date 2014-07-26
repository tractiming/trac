#include <my_global.h>
#include <mysql.h>

#define SUCCESS 0
#define ERROR 1

const char hostname[] = "localhost";
const char username[] = "elliot";
const char password[] = "millie";
const char database[] = "trac";

int process_new_split_data(MYSQL *con);
int update_json_splits(MYSQL *con);
int handle_updates(MYSQL *con);
