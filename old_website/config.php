<?php 

$db_host = 'localhost'; 
$db_user = 'root'; 
$db_pwd = 'root'; 
$database = 'testrfid'; 


mysql_connect($db_host, $db_user, $db_pwd) or die(mysql_error()); 
mysql_select_db($database) or die(mysql_error()); 
   ?>