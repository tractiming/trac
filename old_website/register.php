<?php
include("config.php");			
if(isset($_POST['save']))
{
if($_POST['password']==$_POST['password2']  && !empty($_POST['password']) && !empty($_POST['username']))
//need to prevent blank submissions
{
$password=$_POST['password'];
//$name=$_POST['name'];
$username=$_POST['username'];
$rfidnum=$_POST['rfidnum'];
$coach=$_POST['coach'];
//$weight=$_POST['weight'];
$usertype=$_POST['usertype'];
$rt=mysql_query("SELECT * FROM admin");
$count=mysql_num_rows($rt);
$newid=$count+1;
$query="INSERT INTO admin VALUES($newid,'$username','$password','$usertype','$rfidnum','$coach')";
$result=mysql_query($query);
if($coach=='coach')
{
    $rt2=mysql_query("SELECT * FROM coachstable");
    $count2=mysql_num_rows($rt2);
    $newid2=$count2+1;
    $result2=mysql_query("INSERT INTO coachstable VALUES($newid2,'$username')");
}
else
{
}
header('location: loginPage.php');
}
else
{
$printbelow=1;
//echo"Your Password is invalid";
}
}
?>
<html>
    <head> 
        <title>TRAC Demo site--User Info</title>
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
				<span class="bold"></span> <span></span>
			</div>
			<div class="product-name"></div>
			<div class="product-info">
				<h2>User Information</h2>
			</div>
		</div>
		<!-- Header Wrapper ends -->
		
		<!-- Navigation Tabs starts -->
		<ul class="nav-tabs">
			
		</ul>
		
		<!-- Navigation Tabs starts -->
		
		<!-- Content Wrapper starts -->
		<div class="content">
			<div class="user-info">
			    <form action="" method="post">
				<h2><font color="#5D6770">Create a new account:</font> </h2>
				<div class="left-panel">
					<div class="box right">
					<div class="form-row">
						<label>Name:</label></div>
						<div class="form-row">
						<span><input name="name" value="" id="" type="text" /></span>
					</div>
					<div class="form-row">
						<label>User Name:</label></div>
						<div class="form-row">
						<span><input name="username" value="" id="" type="text" /></span>
					</div>
					<div class="form-row">
						<label>Tag Number:</label></div><div class="form-row">
						<span><input name="rfidnum" value="" id="" type="text" /></span>
					</div>
					<div class="form-row">
						<label>Coach:</label></div><div class="form-row">
						<span><input name="coach" value="" id="" type="text" /></span>
					</div>
					<div class="form-row">
						<label>Weight:</label></div><div class="form-row">
						<span><input name="weight" value="" id="" type="text" /></span>
					</div>
					<div class="form-row">
						<label>Male or Female:</label></div><div class="form-row">
						<span><select name="sex">
									<option value="male">Male</option><option value="female">Female</option>
							</select></span>
					</div>
                                        <div class="form-row">
						<label>User Type:</label></div><div class="form-row">
						<span>
							<select name="usertype">
									<option value="athlete">Athlete</option><option  value="coach">Coach</option>
							</select>
						</span>
					</div>
					
					<div class="form-row">
						<label>Password:</label></div><div class="form-row">
						<span><input name="password" value="" id="" type="text" /></span>
					</div>
					<div class="form-row">
						<label>Verify Password:</label></div><div class="form-row">
						<span><input name="password2" value="" id="" type="text" /></span>
					</div>
					<?php
					if($printbelow==1)
					{
					    echo"<font color='red'>Your Password/Username is invalid</font>";
					}
					?> 
					<div class="form-row button-container">
								<input type="submit" name="save" id="save" value="Save" />
							</div>
					</div>
					
					
				</div>
				

				
				<div class="right-panel">
					<div class="body">
					
					<img src="images/quote.png">
					
					               </div>
					</div>
				</div>
				
			</div>
			</form>
		
		<!-- Content Wrapper ends -->
	    
		<div class="pageFooter" width="1000px">
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