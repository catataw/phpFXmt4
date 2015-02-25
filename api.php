<?php
ini_set('display_errors', 0);
error_reporting(0);
// localhost only 
//if($_SERVER['HTTP_HOST'] != "localhost"){echo "api v. 1.0"; die();}

//========================================================================
// functions
//========================================================================
// db connect
function Connect(){
    $h = 'localhost';
    $u = 'root';
    $j = 'toor';
    $db = 'db';
    mysql_connect($h,$u,$j) or die('[DB_ERROR]');
    mysql_select_db($db) or die('[DB_ERROR]');
    mysql_query("SET character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'");
}

function ConnectOpenShift(){
    $h = getenv('OPENSHIFT_MYSQL_DB_HOST');
    $u = getenv('OPENSHIFT_MYSQL_DB_USERNAME');
    $j = getenv('OPENSHIFT_MYSQL_DB_PASSWORD');
    $db = 'fx';

    mysql_connect($h,$u,$j) or die('[DB_ERROR]');
    mysql_select_db($db) or die('[DB_ERROR]');
    mysql_query("SET character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'");
}

// db close connection
function Close(){
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

//========================================================================
// main
//========================================================================
Connect();
//ConnectOpenShift();

$open  =  htmlentities($_POST["positions"], ENT_QUOTES, 'UTF-8');
$close =  htmlentities($_POST["historyall"], ENT_QUOTES, 'UTF-8');

$user = htmlentities($_POST["user"], ENT_QUOTES, 'UTF-8');
$pass = htmlentities($_POST["pass"], ENT_QUOTES, 'UTF-8');


$account = htmlentities($_POST["account"], ENT_QUOTES, 'UTF-8');

$balance = htmlentities($_POST["balance"], ENT_QUOTES, 'UTF-8');
$equity = htmlentities($_POST["equity"], ENT_QUOTES, 'UTF-8');
$time = time();

if(!userExist($user, $pass)){  /*  echo "[ER_USER]"; */ }

// open and update positions in database
if(!empty($open)){
	// split positions line	
	$openall = explode("|", substr($open, 0,-1));
	
	foreach ($openall as $key => $posstr) {
			//split position			
			$pos = explode(";", $posstr);
			$id = $pos[1];
			$symbol = $pos[3];
			$volume = $pos[4];
			$type = $pos[5];
			if($type == '1'){$type = "sell";}
			if($type == '0'){$type = "buy";}
			$opent = $pos[0];
			$openp = $pos[2];
			$sl = $pos[6];
			$tp = $pos[7];
			$time = time(0);
			$profit = $pos[8];
			$account = $pos[9];
		    // save or update in database
		    // mysql_query("INSERT INTO orders VALUES('$id','$symbol','$volume','$type','$opent','$openp','$sl','$tp','$closet', '$closep', '$profit','$time','$account')");
	        $openadd = mysql_query("INSERT INTO orders VALUES('$id','$symbol','$volume','$type','$opent','$openp','$sl','$tp','0', '0', '$profit','$time','$account') ON DUPLICATE KEY UPDATE volume = '$volume', sl = '$sl', tp = '$tp', profit = '$profit'");
	}
}





// update closed positions in database
if(!empty($close)){
	// split history positions line 	
	$closeall = explode("|", substr($close, 0,-1));
	
	foreach ($closeall as $key => $poshstr) {
			// split history position
			
			$posh = explode(";", $poshstr);
			//print_r($posh);
		    $id = $posh[1];
			$symbol = $posh[3];
			$volume = $posh[4];
			$type = $posh[5];
			if($type == '1'){$type = "sell";}
			if($type == '0'){$type = "buy";}
			$opent = $posh[0];
			$openp = $posh[2];
			$sl = $posh[6];
			$tp = $posh[7];
			$closet = $posh[8];
			$closep = $posh[9];
			$profit = $posh[10];
			$time = time(0);
			$account = $posh[11];

		    // save or update in database
		    // mysql_query("INSERT INTO orders VALUES('$id','$symbol','$volume','$type','$opent','$openp','$sl','$tp','$closet', '$closep', '$profit','$time','$account')");
	    $closeadd = mysql_query("INSERT INTO orders VALUES('$id','$symbol','$volume','$type','$opent','$openp','$sl','$tp','$closet', '$closep', '$profit' , '$time' , '$account') ON DUPLICATE KEY UPDATE volume = '$volume', sl = '$sl', tp = '$tp', closet = '$closet', closep = '$closep', profit = '$profit'");
	}
}	




// add balance to database
$result = mysql_query("SELECT `alias`,`linkmql` FROM users WHERE account = '$account'");

$row = mysql_fetch_row($result);
$alias = $row[0];
$linkmql = $row[1];
if(!empty($alias)){
$ok = mysql_query("INSERT INTO balance VALUES('$account','$balance','$equity','$alias','$linkmql','$time') ON DUPLICATE KEY UPDATE balance = '$balance', equity = '$equity', alias = '$alias', linkmql = '$linkmql', time = '$time'");


	// co 1h  dodaj salda do bazy danych
	$timer = file_get_contents('timer.txt');
	$timer = $timer + (60 * 30);

	if($timer < time()){
	$ok = mysql_query("INSERT INTO balanceall VALUES('$account','$balance','$equity','$time')");
	file_put_contents('timer.txt', time());
	}
}

// db close connection
Close();
// end php code
//echo $account;
echo "[OK]";
die(); 
?>
