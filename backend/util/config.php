<?php

// Database settings and password.
$db_host = "localhost";
$db_user = "elliot";
$db_pwd = "millie";
$database = "trac";
$tag_table = "readerData";
$user_table = "userData";

// Connect to the database.
mysql_connect($db_host, $db_user, $db_pwd) or die(mysql_error());
mysql_select_db($database) or die(mysql_error());

?>
