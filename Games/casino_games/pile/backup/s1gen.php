<?PHP
##############################################################################
# PROGRAM : Casino System                                                    #
# VERSION : 2.00                                                             #
# REVISION: 000										     #
# DATE    : 01/06/2006                                                       #
##############################################################################
# All source code, images, programs, files included in this package          #
# Copyright (c) 2003-2004                                                    #
#		    XL Corp.		  						     #
#           www.xlcorp.co.uk                                                 #
#           www.start-your-casino.com                                        #
#           All Rights Reserved.                                             #
##############################################################################
#                                                                            #
#    While we distribute the source code for our scripts/software and you    #
#    are allowed to edit them to better suit your needs, we do not           #
#    support modified code.  Please see the license prior to changing        #
#    anything. You must agree to the license terms before using this         #
#    software package or any code contained herein.                          #
#                                                                            #
#    Any redistribution without permission of XL Corp.                       #
#    is strictly forbidden.                                                  #
#                                                                            #
##############################################################################

//if ($_SERVER["SERVER_NAME"] != "www.24hr-bet.com") { exit; }
error_reporting(0);
require('../scripts/connect.php');
///////////////////// functions //////////////////////
function calWinLimit(){
	$result=mysql_query("select * from `settings` where `type`='51'");
	$xdate=mysql_result($result, 0, "date");
	$coef=mysql_result($result, 0, "coef");
	// Get max. win. amount for Location ID
	$locID=LOCID;
	$userid=USERID;
	list($balance) = mysql_fetch_row(mysql_query("SELECT SUM(amount) FROM `transactions` WHERE `date`>$xdate AND ((type='w' AND userid='$userid') OR (type='l' AND userid='$userid') OR (type='co' AND comments='$userid'))"));
	$balance=-$balance;
	$maxwin=$balance*$coef/100;
	if($maxwin<0){ $maxwin=0; }
	return $maxwin;
}
//
function Gen(){
	$res=rand(0, 100);
	if( $res<15 ){ $n=6; }
	if( ($res>=15)&&($res<30) ){ $n=5; }
	if( ($res>=30)&&($res<40) ){ $n=4; }
	if( ($res>=40)&&($res<50) ){ $n=3; }
	if( ($res>=50)&&($res<75) ){ $n=2; }
	if( ($res>=75)&&($res<85)) { $n=1; }
	if($res>=85){ $n=0; }
	return $n;
}
//
function countLine($a, $b, $c){
	global $win, $bet;
	if( ($a==$b)&&($b==$c) ){
		switch ($a){
			case 1: $win=1000*$bet; break;
			case 2: $win=250*$bet; break;
			case 3: $win=50*$bet; break;
			case 4: $win=25*$bet; break;
			case 5: $win=10*$bet; break;
		}
	} else {
		if ( ($a > 3) && ($a < 7) && ($b > 3) && ($b < 7) && ($c > 3) && ($c < 7)) {
			$win = 5 * $bet; //Any Bar
		} elseif ( ($a == $b) && ($b == 3) || ($b == $c) && ($b == 3) || ($a == $c) && ($a == 3)) { 
			$win = 5 * $bet; 
		} //2x
		elseif (($a == 3) || ($b == 3) || ($c == 3)) {
			$win = $bet;
		} //1x		
	}
}

///////////////////// MAIN //////////////////////
if( !isset($_POST["b"]) ){ exit; }
if( isset($_POST["uid"]) ){ $sid=$_POST["uid"]; }else{ exit; }
$result=mysql_query("select `userid` from `session` where `sid`='$sid'");
$userid=mysql_result($result, 0, "userid");
$bet=$_POST["b"];

$total_bet = sprintf ("%01.2f", $bet); 

// Real Time check for user balance
list($user_balance) = mysql_fetch_row(mysql_query("SELECT SUM(amount) FROM transactions WHERE userid='$userid'"));
$user_balance = sprintf ("%01.2f", $user_balance); 
if ($user_balance < $total_bet) { exit; }

//Location ID
define("LOCID", substr($userid,0,3));
define("USERID",$userid);

// Update User
//mysql_query("update `users` set `lplay_date`=".time()." where `userid`=$userid");
mysql_query("update `session` set `time`=".time()." where `userid`='$userid'");

//Genuine User Check
//if ($userid == 0) { exit; }

// start game;
do{
	$win=0;
	$n1=Gen(); 
	$n2=Gen();
	$n3=Gen();
	$n4=Gen();
	$n5=Gen();
	$n6=Gen();
	$n7=Gen();
	$n8=Gen();
	$n9=Gen();
//remove 2 blank in a reel 

	if ($n1==$n4){ $n1=Gen();}
	if ($n4==$n7){ $n7=Gen();}
	if ($n1==$n7){ $n7=Gen();}

	if ($n2==$n5){ $n2=Gen();}
	if ($n5==$n8){ $n8=Gen();}
	if ($n2==$n8){ $n8=Gen();}

	if ($n3==$n6){ $n3=Gen();}
	if ($n6==$n9){ $n9=Gen();}
	if ($n3==$n9){ $n9=Gen();}

//remove 2 blank on the pay line

	if (($n4==6)&&($n5==6)) {$n4=Gen(); $n5=Gen();}
	if (($n5==6)&&($n6==6)) {$n5=Gen(); $n6=Gen();}
	if (($n4==6)&&($n6==6)) {$n4=Gen(); $n6=Gen();}

	countLine($n4, $n5, $n6);
	$maxwin=calWinLimit();
}while($win>$maxwin);

//update games and transactions
$win_limit = sprintf ("%01.2f", $maxwin); 
$diff=$win-$bet;
$diff = sprintf ("%01.2f", $diff);
if($diff>=0){$rg="w";}else{$rg="l";
	//auto cashout
	$co_amount=$diff/4;
	$co_amount = sprintf ("%01.2f", $co_amount); 
	$co_amount = -$co_amount;
	$tm=time();
	mysql_query("insert into `transactions` values('', '0', '0', '$tm', 'co', '$co_amount', '$userid')");
}
$tm=time();
mysql_query("insert into `games` values('', '$userid', '$tm', '$bet', '-1', '$rg', '$diff', '51')");
$gameid=mysql_insert_id();
mysql_query("insert into `transactions` values('', '$userid', '$gameid', '$tm', '$rg', '$diff', '$win_limit')");

//user balance
//Optimized
list($user_balance) = mysql_fetch_row(mysql_query("SELECT SUM(amount) FROM transactions WHERE userid='$userid'"));
$user_balance = sprintf ("%01.2f", $user_balance); 

// send answer
$answer="&ans=res&ub=".$user_balance."&wn=".$win."&n1=".$n1."&n2=".$n2."&n3=".$n3."&n4=".$n4."&n5=".$n5."&n6=".$n6."&n7=".$n7."&n8=".$n8."&n9=".$n9;
echo $answer;
?>
