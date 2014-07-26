CC = gcc
INCLUDES = ${shell mysql_config --cflags} -Wall
LIBS = ${shell mysql_config --libs} -lm

all: trac_notif

update.o: update.c update.h cJSON.h
	$(CC) -c $(INCLUDES) update.c

cJSON.o: cJSON.c cJSON.h
	$(CC) -c cJSON.c

trac_notif: update.o cJSON.o
	$(CC) -o trac_notif update.o cJSON.o $(LIBS)
clean:
	rm -f trac_notif update.o cJSON.o
