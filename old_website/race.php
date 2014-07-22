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
	<link rel="stylesheet" href="colorbox.css" />
	<script src="js/jquery-1.11.0.js"></script>
	<script src="js/script.js"></script>
	<script src="../jquery.colorbox.js"></script>
	<script>
			$(document).ready(function(){
				$(".inline").colorbox({inline:true, width:"50%"});
			});
		</script>
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
			<li id="home">HOME</li>
			<li id="userInfo">USER INFO</li>
			<li class="selected" id="race">RACES</li>
			<li id="training">TRAINING LOG</li>
			<li  id="liveView">LIVE LAP TIME</li>
		</ul>
		<form action="signout.php" method="post">
		<input type="submit" name="" value="Sign Out" id="signout" class="signout" />
		</form>
		<!-- Navigation Tabs starts -->
		
		<!-- Content Wrapper starts -->
		<div class="content">
                    <div class="race-box">
                        <div class="left-panel">
                            <div class="picture">



<iframe src="https://mapsengine.google.com/map/u/0/embed?mid=zzktW7boz04w.kn-14FvnhX5A" width="500" height="450" frameborder="0" style="border:0"></iframe>
			    </div>
                        </div>
                        <div class="right-panel">   
                            <h2><font color="#5D6770">Race Results & Registration</h2></font>
                                <div class="inner">
                                    <form>
                                             <div class="form-row"> <h4>North Ave Shuffle (5k), June 8, 2012</h4>
                                                </div>
                                             <div class="form-row"> <center><h4><a class='inline' href="#inline_content1" >104st, 21:54</a></h4></center>
                                                </div>
                                                    <div class="form-row"><h4> Wilson Street Run (5k), July 10, 2012  </h4>
                                                        </div>
                                                    <div class="form-row"> <center><h4><a class='inline' href="#inline_content2" >254th, 20:14</a></h4></center>
                                                </div>
                                                    <div class="form-row"> <h4>Rogers Park to Wilson Run (8k), July 14, 2012</h4>
                                                </div>
                                             <div class="form-row"> <center><h4><a class='inline' href="#inline_content3" >55th, 33:54</a></h4></center>
                                                </div>
                                             
                                                            
                        </div>
                                        
                                          
                                        
                                        
                                 </form>
                         </div>
                    </div>
                 </div>
            <div class="hidden" style='display:none'>
			<div class="one" id='inline_content1' style='padding:10px; background:#fff;'>
			<p><strong>Race Results, June 8th, 2012</strong><br><br>
			<a href="">Full Results</a></p>
			<table>
			    <tr>
				<td rowspan="3">104th, 21:54</td>
				<td>Distance</td>
				<td>1</td>
				<td>2</td>
				<td>3</td>
				
			    </tr>
			    <tr>
				<td>Split</td>
				<td>7:21</td>
				<td>6:54</td>
				<td>7:41</td>
				
			    </tr>
			    <tr>
				<td>Total Time</td>
				<td>7:21</td>
				<td>14:15</td>
				<td>21:54</td>
				
			    </tr>
			</table>
			</div>
			
			<div class="one" id='inline_content2' style='padding:10px; background:#fff;'>
			<p><strong>Race Results, June 8th, 2012</strong><br><br>
			<a href="">Full Results</a></p>
			<table>
			    <tr>
				<td rowspan="3">254th, 20:14</td>
				<td>Distance</td>
				<td>1</td>
				<td>2</td>
				<td>3</td>
				
			    </tr>
			    <tr>
				<td>Split</td>
				<td>6:40</td>
				<td>7:01</td>
				<td>7:33</td>
				
			    </tr>
			    <tr>
				<td>Total Time</td>
				<td>6:40</td>
				<td>13:41</td>
				<td>20:14</td>
				
			    </tr>
			</table>
			</div>
			
			<div class="one" id='inline_content3' style='padding:10px; background:#fff;'>
			<p><strong>Race Results, June 8th, 2012</strong><br><br>
			<a href="">Full Results</a></p>
			<table>
			   
			    <tr>
				<td rowspan="3">55th, 33:54</td>
				<td>Distance</td>
				<td>1</td>
				<td>2</td>
				<td>3</td>
				<td>4</td>
				<td>5</td>
				
			    </tr>
			    <tr>
				<td>Split</td>
				<td>6:30</td>
				<td>6:31</td>
				<td>6:29</td>
				<td>6:53</td>
				<td>9:31</td>
				
			    </tr>
			    <tr>
				<td>Total Time</td>
				<td>6:30</td>
				<td>13:01</td>
				<td>18:30</td>
				<td>24:23</td>
				<td>33:54</td>
				
			    </tr>
			</table>
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