<?php
error_reporting(0);

function Connect(){
    $h = 'localhost';
    $u = 'root';
    $j = 'toor';
    $db = 'db';
    mysql_connect($h,$u,$j) or die('[DB_ERROR]');
    mysql_select_db($db) or die('[DB_ERROR]');
    mysql_query("SET character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'");
}

function userExist($user = "", $pass = "")
{
    if($user != "" && $pass != ""){
        $pass = md5($pass);
        $user = htmlentities($user, ENT_QUOTES, "UTF-8");
        $user = mysql_real_escape_string($user);
        $pass = mysql_real_escape_string($pass);
        $result = mysql_query("SELECT * FROM users where alias = '$user' AND pass = '$pass'");
        $num_rows = mysql_num_rows($result);            
        return $num_rows;
    }else{
        return 0;
    }
}

function providerAccountExist($user = "")
{
  $user = (int)$user;
    if($user > 0){
        $result = mysql_query("SELECT * FROM users where account = '$user'");
        $num_rows = mysql_num_rows($result);            
        return $num_rows;
    }else{
        return 0;
    }
}

/*
  if (!empty($_SERVER['HTTPS']) && ('on' == $_SERVER['HTTPS'])) {
    $uri = 'https://';
  } else {
    $uri = 'http://';
  }
  $uri .= $_SERVER['HTTP_HOST'];
  //header('Location: '.$uri.'/xampp/');
  //exit;
*/

if(empty($_POST['id'])){
   $id=83320406;
   $id=66740257;
}else{
  $id = (int)$_POST['id'];
}

 $user = $_POST['user'];
 $pass = $_POST['pass'];
 $money = (int)$_POST['money'];

 $open = "";
 $close = "";

 Connect();

if(userExist($user,$pass) == 1 && providerAccountExist($id) == 1){
    $result = mysql_query("select * from orders where closet = '0' and account = '$id'");
    while ($row = mysql_fetch_assoc($result)) {
    echo $open = $row['id'].';'.$row['opent'].';'.$row['type'].';'.$row['symbol'].';'.$row['volume'].';'.$row['openp'].';'.$row['sl'].';'.$row['tp'];
    die();
    }

    if($open == ""){
      echo "[EMPTY]";
      die();  
    }
}


if(userExist($user,$pass) != 1){
  echo "[ERROR_LOGIN]";
}else if(providerAccountExist($id) != 1){
  echo "[ERROR_PROVIDER]";
}

// $str = $str.$row['id'].';'.$row['opent'].';'.$row['type'].';'.$row['symbol'].';'.$row['volume'].';'.$row['openp'].';'.$row['sl'].';'.$row['tp'].';'.$row['closet'].';'.$row['closep'].';'.$row['profit'].'|';
?>
