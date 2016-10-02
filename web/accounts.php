<?php
include 'include/login.php';
if (!isset($_SESSION['username']){
header("Location: /");
die();
}

session_start();
include 'include/header.php';

if($_SESSION['username'] !== "admin"){
?>

<body>
<br />
<br />
<div class="container">
<div class="row">
<div class="col-md-4 col-center">
<div class="jumbotron">
<h2 style="text-align: center"><b>Access Denied</b></h2>
<br />
<p style="text-align: center">You do not have permission to manage accounts. Click <a href="/">here</a> to go back.</p>
</div>
</div>
</div>
</div>
</body>
</html>

<?php
} else {
?>


<body>
<br />
<br />
<div class="container">
<div class="jumbotron">
<h2><b>FlamesCP 2 - Account Manager</b><span style="font-size: 12px">&nbsp;&nbsp;<a href="/">Return to dashboard</a></span></h2>
<br />
<br />
<?php
if ($_POST['act'] == "remove" && !empty($_POST['account'])){

if ($_POST['account'] == "admin"){
echo '<div class="alert alert-info"><b>This account is protected.</b></div>';
} else {
$delquery = $conn->prepare('delete from login where username=:userdel');
$delquery->bindParam(':userdel', $_POST['account']);
$delquery->execute();
echo '<div class="alert alert-danger"><b>The account '.$_POST['account'].' has been removed.</b></div>';
}

}
?>
<div class="table-responsive">
<table class="table table-bordered">
<thead>
<tr>
<th>Account ID</th>
<th>Username</th>
<th>Actions</th>
</tr>
</thead>
<tbody>
<?php
$query = $conn->prepare('select * from login');
$query->execute();

foreach ($query as $row) {

echo '<tr>';

echo '<td>'.$row["id"].'</td>';
echo '<td>'.$row["username"].'</td>';

if ($row['id'] == "1"){
echo '<td>N/A</td>';
} else {
echo '<td><form action="accounts.php" method="POST"><input type="hidden" name="act" value="remove"><input type="hidden" name="account" value="'.$row["username"].'"><input class="btn btn-danger btn-block" value="Remove account" type="submit"></form></td>';
}

echo '</tr>';

}
?>
</tbody>
</table>
</div>
<br />
<h3>Create account</h3>
<br />
<?php
if ($_POST['act'] == "create"){
  if (empty($_POST['username']) || empty($_POST['password'])){
    echo '<div class="alert alert-info"><b>Seems like you missed something.</b></div>';
  } else if($_POST['password'] !== $_POST['conf_password']) {
    echo '<div class="alert alert-info"><b>Password doesn\'t match.</b></div>';
  } else {

    $check = $conn->prepare('select * from login where username=:account');
    $check->bindParam(':account', $_POST['username']);
    $check->execute();
  
    if ($check->rowCount() > 0) {
  
      echo '<div class="alert alert-danger"><b>The username has already been taken.<b/></div>';
  
    } else {
  
      $create = $conn->prepare('insert into login (username, password, status) VAlUES (:username, :password, "admin");');
      $create->bindParam(':username', $_POST['username']);
      $create->bindParam(':password', password_hash($_POST['password'], PASSWORD_BCRYPT, $bcrypt_opt));
      $create->execute();
  
      echo '<div class="alert alert-success">Account created. Click <a href="accounts.php">here</a> to reload the page.</div>';
  
    }
  }
}
?>
<form action="accounts.php" method="POST">
<input name="act" type="hidden" value="create">
<input class="form-control" name="username" placeholder="The account's username...">
<br />
<input class="form-control" name="password" placeholder="The account's password..." type="password">
<br />
<input class="form-control" name="conf_password" placeholder="Confirm Password..." type="password">
<br />
<input class="btn btn-success btn-block" type="submit" value="Create account">
</form>
</div>
</div>
</body>
</html>

<?php } ?>
