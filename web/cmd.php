<?php
include 'include/login.php';
if (!isset($_SESSION['username']){
header("Location: /");
die();
}

$cmd = $_POST['cmd'];

file_put_contents("/var/run/flamescp.sock", $cmd."\n", FILE_APPEND | LOCK_EX);
echo '<div class="alert alert-success"><b>The command was executed.</b></div>';

?>
