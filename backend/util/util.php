<?php
/* 
 * This is a utility tool for managing the backend of the trac database.
 *
 *
 */

// Database settings and password.
$db_host = "localhost";
$db_user = "elliot";
$db_pwd = "millie";
$database = "trac";
$tag_table = "readerData";
$user_table = "userData";

date_default_timezone_set('America/New_York');

// Connect to the database.
function db_connect()
{
    global $db_host, $db_user, $db_pwd, $database;
    $db = new mysqli($db_host, $db_user, $db_pwd, $database);
    if($db->connect_errno)
    {
        die("Unable to connect to database [" . $db->connect_error . "]\n");
    }
    return $db;
}

function make_query($db, $query)
{
    if (!$result = $db->query($query))
    {
        die("Error running query [".$db->error . "]\n");
    }
    return $result;
}

/* Adds a user to the userData table. */
function add_user($db, $fname, $lname, $username, $tagID)
{
    // Note: the user name must be unique or the entry won't be added. 
    $query = "INSERT IGNORE INTO userData (first_name, last_name, username, tag_id1)"
             ." VALUES (\"{$fname}\", \"{$lname}\", \"{$username}\", \"{$tagID}\")";
    $result = make_query($db, $query);
}

function test_add_user()
{
    $db = db_connect();
    
    $fname = 'Jeff';
    $lname = 'Thode';
    $username = 'tigertattoo';
    $tagID = '11C6 00E4';

    add_user($db, $fname, $lname, $username, $tagID);
}

/* Creates a workout for a given set of readers. */
function create_workout($db, $name, $readers)
{
    // First check if the workout already exists. If so, return.
    $test_query = "SELECT sessionID FROM sessionData WHERE sessionID=$name";
    $result = make_query($db, $test_query);
    if($result->num_rows > 0)
    {
        echo "Workout already exists!\n";
        return;
    }

    // Add the workout row.
    $add_query = "INSERT INTO sessionData (sessionID) values (${name})";
    make_query($db, $add_query);

    // Add readers to the session.
    $num_readers = count($readers);
    if ($num_readers>5) 
    {
        $num_readers = 5;
    }
    for ($k=0; $k<$num_readers; $k++)
    {
        $r_string = "R" .($k+1);
        make_query($db, "UPDATE sessionData SET ${r_string}=${readers[$k]} "
                       ."WHERE sessionID=$name");
    }
    return;
}

/* Sets the start time of a workout. */
function start_workout($db, $w_name, $start_time)
{
    make_query($db, "UPDATE sessionData SET startTime=\"${start_time}\" "
                   ."WHERE sessionID=${w_name}");
}

/* Sets stop time. Effectively tells trac to stop processing splits for this w_id. */
function stop_workout($db, $w_name, $stop_time)
{
    make_query($db, "UPDATE sessionData SET stopTime=\"${stop_time}\" "
                   ."WHERE sessionID=${w_name}");
}

function test_create_workout()
{
    
    $db = db_connect();
    $reader_ids = array(1,2);
    $w_name = 789;

    create_workout($db, $w_name, $reader_ids);
 
    
    $start_time = date('Y-m-d H:i:s');
    start_workout($db, $w_name, $start_time);

    sleep(5);
    
    $stop_time = date('Y-m-d H:i:s');
    stop_workout($db, $w_name, $stop_time);

}

/* Erases all times/splits for the given workout. */
function clear_workout_data($db, $w_name)
{
    make_query($db, "DELETE FROM splitData WHERE workoutID=${w_name}");
}

function get_splits($db, $w_name, $tag_id_int)
{
    $result =make_query($db, "SELECT (TIMESTAMPDIFF(SECOND, (SELECT MIN(time) FROM "
                 ."splitData WHERE (workoutID=${w_name} AND tagID=${tag_id_int})), time)) "
                 ."AS dt FROM splitData WHERE (workoutID=${w_name} AND "
                 ."tagID=${tag_id_int}) ORDER BY dt ASC");
    


}

if (!debug_backtrace()) 
{

    //test_add_user();
    test_create_workout(); 

}



?>
