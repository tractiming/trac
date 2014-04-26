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
			<li class="selected" id="home">HOME</li>
                        <li id="userInfo">USER INFO</li>
			<li id="race">RACES</li>
			<li id="training">TRAINING LOG</li>
			<li id="liveView">LIVE LAP TIME</li>
		</ul>
		<form action="signout.php" method="post">
		<input type="submit" name="" value="Sign Out" id="signout" class="signout" />
		</form>
		<!-- Navigation Tabs starts -->
                <!--content ends-->
		
	<div class="content">
			<div class="graph-area">
				<div class="left">
					<div class="inner">
				 <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
         ['', 'link','Miles per Week'],
          ['Sunday', 'activityLevel.html', 6],
          ['Monday', 'activityLevel.html', 4],
          ['Tuesday', 'activityLevel.html', 8],
          ['Wednesday', 'activityLevel.html', 12],
          ['Thursday', 'activityLevel.html', 6]
        ]);

        var view = new google.visualization.DataView(data);
        view.setColumns([0, 2]);

        var options = {
  width: 500,
  height: 400,
  colors: ['#a21984', '#f47a47', '#005580', '#c0c9dd', '#8dc63f'], title:"Miles This Week",titleTextStyle:{color:'#FFFFFF', fontSize: 16}, backgroundColor: '#3577A8',legend:{textStyle:{color:'#FFFFFF'}},
};



        var chart = new google.visualization.PieChart( 
          document.getElementById('visualization'));
        chart.draw(view, options);

        var selectHandler = function(e) {
         window.location = data.getValue(chart.getSelection()[0]['row'], 1 );
        }

        // Add our selection handler.
        google.visualization.events.addListener(chart, 'select', selectHandler);
      }
    </script>
  </head>
  <body>
    <div id="visualization" style="width: 600px; height: 400px;"></div>
  </body>
		</div>				
</div>
<div class="right">
<div class="upper-boarder">
	<div class="inner">
          <br><h3>Saturday, April 26 2014</h3§>
            <div class="graph">
                
                <img  src="images/chi.jpg">
                    
                
            </div>
        </div>
</div>
<div class="lower-boarder">
	<div class="outer">
		 <Br><H5> FRIEND'S RUNNING LOGS:<BR>
                 <div class="table">
            <TABLE >
                <tr>
                <td><h5></h5></td>
                 <td><h5></h5></td>
                <td><h5>Distance</h5></td>
                <td><h5>Time</h5></td>
                  <td><h5>Pace</h5></td> 
                </tr>
                <tr>
                <td><img src="images/e.png"></td>    
                <td><h5>Elliot</h5></td>
                <td><h5>17 miles</h5></td>
                <td><h5>1:42:14</h5></td>
                <td><h5>6:01</h5></td>
                </tr>
                <tr>
                <td><img src="images/g.png"></td>  
                <td><h5>Griffin</h5></td>
                <td><h5>17 miles</h5></td>
                <td><h5>1:42:15</h5></td>
                  <td><h5>6:01</h5></td> 
                </tr>
                <tr>
                    <td><img src="images/alex.png"></td>  
                <td><h5>Alex</h5></td>
                <td><h5>12 miles</h5></td>
                <td><h5>1:20:00</h5></td>
                  <td><h5>7:30</h5></td> 
                </tr>
                
            </TABLE>
	
                 </div>
	</div>
	
</div>
</div>
			</div>
		</div>
        <!--Content Ends-->
	    
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