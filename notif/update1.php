<?php

// Connect to database.
include("config.php");
mysql_connect($db_host, $db_user, $db_pwd) or die(mysql_error());
mysql_select_db($database) or die(mysql_error());

// Loop while checking for new any entries in the tag table.
$notif_query = "SELECT * FROM $tag_table WHERE parsed=0" ;
while(1)
{
	$result = mysql_query($notif_query);
	if ($result)
	{
		$data = array();
		while($row = mysql_fetch_array($result))
		{
			// Get the runner's name from the tag ID.
			$id = $row['tagID'];
			$name_query = "SELECT * FROM $user_table WHERE tag_id1=$id LIMIT 1";
			$name_res = mysql_query($name_query);
			if (!$name_res)
			{
				$name = "Unknown";			
			}
			else 
			{
				$nrow = mysql_fetch_array($name_res);
				$name = $nrow['first_name'];
			}	
			
			// Get the time the tag was read.
			$time_new = $row['tagTime'];
			$posts[] = array('name'=> $name, 'interval'=> array($time_new));
			echo "$time_new";

			// Update the state of the tag to read.
			$up_res = mysql_query("UPDATE $tag_table SET parsed=1");
		}
	}
}

?>
