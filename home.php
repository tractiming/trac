<?php
if (isset($_COOKIE["username"]))
{
$printhome=1; 
}
else
{
header('Location: loginPage.php');
}
?>
<html>
    <head> 
        <title>TRAC Demo site</title>
	<link rel="stylesheet" type="text/css" href="css/style.css" />
	<script src="js/jquery-1.4.2.min.js"></script>
	<script src="js/script.js"></script>
    </head>

<body class="theme1">
	<!-- Main Container tarts -->
	<div class="main-container">
		<!-- Header Wrapper starts -->
		<div class="header no-border">
			<div class="user-details">
				<span class="bold">Welcome:</span> <span><?php
				if($printhome==1)
				{
				echo $_COOKIE['username'];
				}
				else
				{}
				?></span>
			</div>
			<div class="product-name"></div>
			<div class="product-info">
				<h2> Live Lap Time Information</h2>
			</div>
		</div>
		<!-- Header Wrapper ends -->
		
		<!-- Navigation Tabs starts -->
		<ul class="nav-tabs">
			<li id="userInfo">USER INFO</li>
			<li id="race">RACES</li>
			<li id="training">TRAINING LOG</li>
			<li class="selected" id="home">LIVE LAP TIME</li>
		</ul>
		<form action="signout.php" method="post">
		<input type="submit" name="" value="Sign Out" id="signout" class="signout" />
		</form>
		<!-- Navigation Tabs starts -->
		
		<!-- Content Wrapper starts -->
		<div class="content">
		<div class="active-area">
			<div class="box">
			<div class="upper-area">
				<div class="inner">
					
			
    
  
  <body>
    <div id="graph" style="width: 900px; height: 300px;">
        <h3>
            <center>
                Test Database
        <!--Call php and javascript code here-->
<?php 

include("config.php");
$table = 'practice'; 

mysql_connect($db_host, $db_user, $db_pwd) or die(mysql_error()); 
mysql_select_db($database) or die(mysql_error()); 

// Filter the records 
if($_COOKIE["usertype"]=="athlete")
{
$liverfid=$_COOKIE['rfidnum'];
$query="SELECT * FROM $table WHERE Tag='$liverfid'"; $result=mysql_query($query);


// I'm holding off on the pace calculation until I figure out how to add info 
// into the database.
//$result = mysql_query("select a.Date, timediff( (select b.Date from {$table} b where b.ID = a.ID + 1),a.Date ) as Pace from {$table} a") ; 
if (!$result) { 
die("Query to show fields from table failed data access ITEMS"); 
} 


$numrows=mysql_num_rows($result); 
echo "<table>"; 

while($row = mysql_fetch_row($result)) 
{ 
echo "<tr>"; 

foreach($row as $cell){ 
echo "<td>$cell</td>"; 
} 
echo "</tr>"; 

} 
echo "</table>"; 

mysql_free_result($result);
}
else
{
//create add userbar to top of screen
//echo "<form action='' method='post'><div> <label>Add Username:</label>
//<input name='adduser' value='' id='' type='text' /><input type='submit' name='save' id='save' value='Save' /></div></form>";
//if posted add the user to coaches personal database "coachestable"
//dynamically allows addition of users
//if(isset($_POST['save']))
//{
//    $sqlloopquery="SELECT * FROM $coachstable";
//    $loopquery=mysql_query($sqlloopquery);
//    $rownum=mysql_num_rows($loopquery);
//    $newrow=$rownum+1;
//    $adduser=$_POST['adduser'];
//    $buttonpost="INSERT INTO $coachstable VALUES($newrow,'$adduser')";
//    $posted=mysql_query($buttonpost);
//}
$coachstable='coachstable';
$sqlloopquery2="SELECT * FROM $coachstable";
$loopquery2=mysql_query($sqlloopquery2);
$rownumloop=mysql_num_rows($loopquery2);
//echo"<h1>$rownumloop</h1>";
//for number of cells in coaches database, query each person invididually into their own table within the page
for($i=1;$i<=$rownumloop;$i++)
{
    //select each person individiually
    $query1=mysql_query("SELECT username FROM coachstable WHERE ID=$i");
    $query12=mysql_fetch_row($query1);
   // echo"$query12[0]";
    $query2=mysql_query("SELECT rfidnum FROM admin WHERE username='$query12[0]'");
    $query22=mysql_fetch_row($query2);
   // echo"$query22[0]";
    $queryb="SELECT Date FROM $table WHERE Tag='$query22[0]'"; $resultb=mysql_query($queryb);

// I'm holding off on the pace calculation until I figure out how to add info 
// into the database.
//$result = mysql_query("select a.Date, timediff( (select b.Date from {$table} b where b.ID = a.ID + 1),a.Date ) as Pace from {$table} a") ; 
echo" <br>$query12[0]";
if (!$resultb) { 
die("Query to show fields from table failed data access ITEMS"); 
} 


$numrowsb=mysql_num_rows($resultb); 
echo "<table>"; 

while($rowb = mysql_fetch_row($resultb)) 
{ 
echo "<tr>"; 

foreach($rowb as $cellb){ 
echo "<td>$cellb</td>"; 
} 
echo "</tr>"; 

} 
echo "</table>"; 

mysql_free_result($resultb);

}
}
?>

            </center>
        
        </h3>
    </div>
  </body>
  
  </div>
  </div>
<div class="lower-area">
	<div class="inner">
		<head>
    
  </head>
  <body>
    <div id="graph-down" style="width: 600px; height: 400px;">
        <!--Call php and javascript code here-->
        
        
    </div>
  </body>
		
	</div>
	
	
</div>
		</div>
		</div>
		</div>
		<!-- Content Wrapper ends -->
	    
		<!-- Footer Wrapper starts -->
		<div class="pageFooter">
			<div class="compbase parbase globalfooter">
				<div class="centerContainer">
					<div class="contactModule gridRight">
						<label>Share</label>

						<a href="" target="_new" class="linkedin"></a>
						
					</div>
					<div class="signUp gridRight">
						<div class="newslettersignup newsletter"></div>
					</div>
					<a href="/en/home.html">
						<img alt="Logo" title="traclogo" class="cq-dd-image" src="images/traclogo_small.png">
					</a>
					<div class="contactModule bottom">
						<span class="copyright">&copy; 2014 Timing and Racing Around the Clock LLC. All rights reserved.</span>
						<span class="links">
							<a href="" target="_new">Locations</a>
							<a href="l" target="_new">Legal &amp; Privacy Notices</a>
							<a href="" target="_new">Contact Us</a>
						</span>
					</div>
				</div>
			</div>
		</div>
		<!-- Footer Wrapper ends -->
		
	</div>
	<!-- Main Container ends -->
</body>
</html>