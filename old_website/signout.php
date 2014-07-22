<?php
if($_SERVER["REQUEST_METHOD"] == "POST")
{
// username and password sent from Form 
setcookie('username', "", time()-360000);
setcookie('password', "", time()-360000);
setcookie('usertype', "", time()-360000);
setcookie('rfidnum', "", time()-360000);
header('location: loginPage.php');
}
else
{
}
?>