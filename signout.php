<?php
if($_SERVER["REQUEST_METHOD"] == "POST")
{
// username and password sent from Form 
$_COOKIE['username']='';
setcookie('username', "", time()-360000);
$_COOKIE["password"]="";
header('location: loginPage.php');
}
else
{
}
?>