<?php
if (isset($_COOKIE["username"]))
{
$printtrain=1; 
}
else
{
header('Location: loginPage.php');
}
?>

<html>
    <head> 
        <title>TRAC Demo site--Training</title>
	<link rel="stylesheet" type="text/css" href="css/style.css" />
	<link rel="stylesheet" href="colorbox.css" />
	<script src="js/jquery-1.4.2.min.js"></script>
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
				if($printtrain==1)
				{
				echo $_COOKIE['username'];
				}
				else
				{}
				?></span>
			</div>
			<div class="product-name"></div>
			<div class="product-info">
				<h2>Training Log</h2>
			</div>
		</div>
		<!-- Header Wrapper ends -->
		
		<!-- Navigation Tabs starts -->
		<ul class="nav-tabs">
			<li id="home">HOME</li>
			<li id="userInfo">USER INFO</li>
			<li id="race">RACES</li>
			<li class="selected id="training">TRAINING LOG</li>
			<li id="liveView">LIVE LAP TIME</li>
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
<iframe src="https://www.google.com/maps/embed?pb=!1m10!1m8!1m3!1d2968.3243196513286!2d-87.63383800000001!3d41.928881865927806!3m2!1i1024!2i768!4f13.1!5e0!3m2!1sen!2sus!4v1396896339365" width="500" height="450" frameborder="0" style="border:0"></iframe>                            </div>
                        </div>
                        <div class="right-panel">   
                            <h2><font color="#5D6770">Past Runs</h2></font>
                                <div class="inner">
                                    <form>
                                              <!--<div class="form-row"> <label>August 12/10 miles/1:12:44</label>
                                                </div>
                                            
                                        
                                                    <div class="form-row"> <label>August 11/4.5 miles/00:31:01</label>
                                                        </div>
                                                    
                                                    <div class="form-row"> <label>August 10/15 miles/1:59:42</label>
                                                </div>
                                             <div class="form-row"> <label>August 3/6 miles/00:42:11</label>
                                                </div>
                                             
                                            <div class="form-row"> <label>August 1/10 miles/1:25:15</label>
                                                </div>
                                             
                                             -->
                                             <h4><font color="#5D6770">Chicago Lakefront Runs</font></h4>
                                             <br>
                                             <table style="width:300px">
                                                <tr>
                                                  <td><u>Date</u></td>
                                                  <td><u>Distance</u></td> 
                                                  <td><u>Time</u></td>
                                                </tr>
                                                <tr>
                                                  <td><p><a class='inline' href="#inline_content1">August 12</a></p></td>		
                                                  <td>10 miles</td> 
                                                  <td>1:12:44</td>
                                                </tr>
                                                 <tr>
                                                  <td><p><a class='inline' href="#inline_content2">August 11</a></p></td>
                                                  <td>4.5 miles</td> 
                                                  <td>00:31:01</td>
                                                </tr>
                                                  <tr>
                                                  <td><p><a class='inline' href="#inline_content3">August 10</a></p></td>
                                                  <td>15 miles</td> 
                                                  <td>1:59:36</td>
                                                </tr>
                                                   <tr>
                                                  <td><p><a class='inline' href="#inline_content4">August 3</a></p></td>
                                                  <td>6 miles</td> 
                                                  <td>00:42:12</td>
                                                </tr>
                                                    <tr>
                                                  <td><p><a class='inline' href="#inline_content5">August 1</a></p></td>
                                                  <td>10 miles</td> 
                                                  <td>1:25:15</td>
                                                </tr>
                                                
                                                </table>
                                             <br>
                                             <h4><font color="#5D6770">Northwestern Uni. T&F RFID Reader</font></h4>
                                             <br>
                                             <table style="width:300px">
                                                <tr>
                                                  <td><u>Date</u></td>
                                                  <td><u>Workout</u></td> 
                                                  <td><u>Splits</u></td>
                                                </tr>
                                                <tr>
                                                  <td><p><a class='inline' href="#inline_content6">August 9</a></p></td>
                                                  <td>4x400m</td> 
                                                  <td>69,67,64,62</td>
                                                </tr>
                                                 <tr>
                                                  <td><p><a class='inline' href="#inline_content7">August 7</a></p></td>
                                                  <td>4x800</td> 
                                                  <td>2:31,2:31,2:30,2:18</td>
                                                </tr>
                                                 <tr>
                                                  <td><p><a class='inline' href="#inline_content8">August 6</a></p></td>
                                                  <td>3x1 mile</td> 
                                                  <td>5:00,4:58,4:44</td>
                                                </tr>
                                            
                                                
                                                </table>
                                                            
                        </div>
                                        
                                          
                                        
                                        
                                 </form>
                         </div>
                    </div>
                 </div>
            <div style='display:none'>
			<div id='inline_content1' style='padding:10px; background:#fff;'>
			<p><strong>Splits from August 12</strong></p>
			<table>
			    <tr>
				<td>.5</td>
				<td>1</td>
				<td>1.5</td>
				<td>2</td>
				<td>2.5</td>
				<td>3</td>
				<td>3.5</td>
				<td>4</td>
				<td>4.5</td>
				<td>5</td>
				<td>5.5</td>
				<td>6</td>
				<td>6.5</td>
				<td>7</td>
				<td>7.5</td>
				<td>8</td>
				<td>8.5</td>
				<td>9</td>
				<td>9.5</td>
				<td>10</td>
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

