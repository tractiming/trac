CC = gcc
INCLUDES = ${shell mysql_config --cflags} -Wall
LIBS = ${shell mysql_config --libs} -lm

all: trac_monitor

update.o: update.c update.h cJSON.h
	$(CC) -c $(INCLUDES) update.c

cJSON.o: cJSON.c cJSON.h
	$(CC) -c cJSON.c

main.o: main.c update.h
	$(CC) -c $(INCLUDES) main.c

trac_monitor: update.o cJSON.o main.o
	$(CC) -o trac_monitor main.o update.o cJSON.o $(LIBS)
clean:
	rm -f trac_monitor update.o cJSON.o main.o
