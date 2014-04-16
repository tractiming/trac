<?php
if (isset($_COOKIE["username"]))
{
$printrace=1; 
}
else
{
header('Location: loginPage.php');
}
?>

<html>
    <head> 
        <title>TRAC Demo site--RACE</title>
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
				if($printrace==1)
				{
				echo $_COOKIE['username'];
				}
				else
				{}
				?>
				</span>
			</div>
			<div class="product-name"></div>
			<div class="product-info">
				<h2>Races</h2>
			</div>
		</div>
		<!-- Header Wrapper ends -->
		
		<!-- Navigation Tabs starts -->
		<ul class="nav-tabs">
			<li id="userInfo">USER INFO</li>
			<li class="selected" id="race">RACES</li>
			<li id="training">TRAINING LOG</li>
			<li  id="home">LIVE LAP TIME</li>
		</ul>
		<input type="button" name="" value="Sign Out" id="signout" class="signout" />
		<!-- Navigation Tabs starts -->
		
		<!-- Content Wrapper starts -->
		<div class="content">
                    <div class="race-box">
                        <div class="left-panel">
                            <div class="picture">
<iframe src="https://mapsengine.google.com/map/u/0/embed?mid=zzktW7boz04w.kn-14FvnhX5A" width="500" height="450" frameborder="0" style="border:0"></iframe>                            </div>
                        </div>
                        <div class="right-panel">   
                            <h2><font color="#5D6770">Race Results & Registration</h2></font>
                                <div class="inner">
                                    <form>
                                             <div class="form-row"> <h4>North Ave Shuffle (5k), June 8, 2012</h4>
                                                </div>
                                             <div class="form-row"> <center><h4>104st, 21:54</h4></center>
                                                </div>
                                                    <div class="form-row"><h4> Wilson Street Run (5k), July 10, 2012  </h4>
                                                        </div>
                                                    <div class="form-row"> <center><h4>254th, 20:14</h4></center>
                                                </div>
                                                    <div class="form-row"> <h4>Rogers Park to Wilson Run (8k), July 14, 2012</h4>
                                                </div>
                                             <div class="form-row"> <center><h4>55th, 33:54</h4></center>
                                                </div>
                                             
                                                            
                        </div>
                                        
                                          
                                        
                                        
                                 </form>
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