<?php
ini_set('display_errors', 0);
error_reporting(0);
// localhost only 
if($_SERVER['HTTP_HOST'] != "localhost"){echo ""; die();}

//========================================================================
// functions
//========================================================================
function redirectSSL()
{
    if($_SERVER["HTTPS"] != "on") {
       header("HTTP/1.1 301 Moved Permanently");
       header("Location: https://" . $_SERVER["SERVER_NAME"] . $_SERVER["REQUEST_URI"]);
       exit();
    }    
}

function Connect(){

    $h = 'localhost';
    $u = 'root';
    $j = 'toor';
    $db = 'db';
    $link = mysql_connect($h,$u,$j) or die('DB_ERROR');
    mysql_select_db($db, $link) or die('DB_ERROR');
}

function close(){
    mysql_close();
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

function logRequest(){
$request = " POST:" .serialize($_POST);
$request = $request . " GET:" . serialize($_GET);
$request = $request . " IP:" . serialize($_SERVER['REMOTE_ADDR']);

}


function PositionClosed($posid = "", $accountid = ""){
    if($posid != "" && $posid != 0 && $account != "" && $account != 0){        
        $posid = htmlentities($posid, ENT_QUOTES, "UTF-8");
        $posid = mysql_real_escape_string($posid);        
        $result = mysql_query("SELECT * FROM shortorders where positionid = '$posid' AND accountid = '$account' AND closeprice != '0' AND closetime != '0'");
        $num_rows = mysql_num_rows($result);            
        return $num_rows;
    }
}

function PositionAdd(){
    // open
    $account = $_POST["accountid"];
    $posid = $_POST["positionid"];
    $pos = $_POST["position"];
    //history
    $haccount = $_POST["haccountid"];
    $hposid = $_POST["hpositionid"];
    $hpos = $_POST["hposition"];

    $hclosetime = $_POST["hclosetime"];
    $hcloseprice = $_POST["hcloseprice"];
    $hprofit = $_POST["hcloseprofit"];

    $command = $_POST["command"];
    $end = $_POST["end"];
    $time = microtime();

    if(!PositionClosed($posid,$account)){
        if($end != "" && $account != "" && $posid != "" && $pos != "" && $command == "[ADD]"){

            mysql_query("INSERT INTO shortorders VALUES('$posid','$pos',0,0,0,'$account','$time') ON DUPLICATE KEY UPDATE position = '$pos'");
            if(mysql_error()){
                echo "[EROO]";
                die();
            };

            //$login = $user . "#". $pass;    
            $res= $account .";". $posid .";". $pos .";". $end;
            //file_put_contents('position.txt', $login. "#" .$res);
            echo $res;
            die();

        }else if($end != "" && $haccount != "" && $hposid != "" && $hpos != "" && $hclosetime != "" && $hcloseprice != "" && $hprofit != "" && $command == "[CLOSE]"){

            // dodac update closetime price profit etc
            mysql_query("INSERT INTO shortorders VALUES('$hposid','$hpos','$hclosetime','$hcloseprice','$hprofit','$haccount','$time') ON DUPLICATE KEY UPDATE position = '$hpos', closetime = '$hclosetime',closeprice = '$hcloseprice', profit = '$hprofit'");
            if(mysql_error()){
                echo "[ER]";
                die();
            };
            $res1= $haccount .";". $hposid .";". $hpos .";". $hclosetime. ";" . $hcloseprice . ";" . $hprofit . $end;
            //file_put_contents('position.txt', $login. "#" .$res);
            echo $res1;            
        }        
    }else{
        echo "[OR_CLOSED]";
    }
}


// Main 
Connect();
$user = $_POST["user"];
$pass = $_POST["pass"];

if(userExist($user, $pass)){
    PositionAdd();
    close();
}else{
    echo "[ER_LOGIN]";
}

?>
