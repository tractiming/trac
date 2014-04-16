<?php
include("config.php");
//change roots more easily in config.php
session_start();
if($_SERVER["REQUEST_METHOD"] == "POST")
{
// username and password sent from Form 
$myusername=addslashes($_POST['username']); 
$mypassword=addslashes($_POST['password']); 

$sql="SELECT id FROM admin WHERE username='$myusername' and passcode='$mypassword'";
//sql table is of form: CREATE TABLE admin
//id INT PRIMARY KEY AUTO_INCREMENT,
//username VARCHAR(30) UNIQUE,
//passcode VARCHAR(30),
//usertype VARCHAR(30)


$result=mysql_query($sql);
$row=mysql_fetch_array($result);
$active=$row['active'];
$count=mysql_num_rows($result);


// If result matched $myusername and $mypassword, table row must be 1 row
if($count==1)
{
if (isset($_POST['PersistentCookie'])) {
/* Set cookie to last 1 year */
setcookie('username', $myusername, time()+3600);
setcookie('password', $mypassword, time()+3600);
}
else {
/* Cookie expires when browser closes */
setcookie('username', $myusername, false, '/', 'www.trac.com');
setcookie('password', $mypassword, false, '/', 'www.trac.com');
//late need to do md5($_POST['password']); to encrypt
}
header('Location: home.php');
}
else 
{
$printdown=1;   
}
}
?>
<html>
	<head>
<meta http-equiv="PRAGMA" content="NO-CACHE" />
<meta http-equiv="Expires" content="-1" /><title>Sign In</title>

<link rel="stylesheet" type="text/css" href="css/style.css" />
<script src="js/jquery-1.4.2.min.js"></script>
<script src="js/script.js"></script>
</head>
<body class="theme1">
<!-- Main Container tarts -->
<div class="main-container"><!-- Header Wrapper starts -->
<div class="header">
<div class="product-name"></div>
<div style="text-align: center;" class="product-info">
<h2>Timing and Racing Around the Clock</h2>
</div>
</div>
<!-- Header Wrapper ends --><!-- Content Wrapper starts -->
<div class="content" > 
<div class="login-box">
<div class="left-panel">
	<div class="sub">
	<div class="textarea">
		<br>
		<center><h2>Sign up and race your friends!</h2></center>
		<div class="button-container">
			
		<input name="" value="Register Now!" id="register" type="button" />
		</div>
	</div>
	
	<div class="picture">
		
	<img src="images/chicago.png" /></div></div></div>
<div class="right-panel">
<h2><font color="#5D6770">Sign In</h2></font>
<div class="inner">
	
	<!--Query SQL Database for username-->
	
	
<form action="" method="post">
<div class="form-row"> <label>User ID</label>
<input name="username" value="" id="" type="text" /></div>
<div class="form-row"> <label>Password</label>
<input name="password" value="" id="" type="password" /></div>
<?php
if($printdown==1)
{
echo"<font color='red'>Your Password/Username is invalid</font>";
}
?>
<div class="long-row">
	<div class="middle">
<div class="button-container"> 

<input name="" value="Sign In" id="signin" type="submit" /></div>
<div class="check"> 
<input type="checkbox" name="PersistentCookie" id="PersistentCookie" value="1" checked="checked"> Stay signed in
 </div>
</div>
</div>
</div>

</form>
</div>
</div>
</div>
<div class="login-box">
<div class="under">

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