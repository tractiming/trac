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
$table = 'admin'; 

mysql_connect($db_host, $db_user, $db_pwd) or die(mysql_error()); 
mysql_select_db($database) or die(mysql_error()); 

// Filter the records 

$query="SELECT * FROM admin"; $result=mysql_query($query);


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