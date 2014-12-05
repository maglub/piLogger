<?php
	////////////////////////////////////////////////////////////
	///
	///    Define Include-ROOT
	///
	////////////////////////////////////////////////////////////

	$stub_version = "1.45 - Supporting WAP and WAMP on Vista!";

	////////////////////////////////////////////////////////////
	///
	///   Non-Secret settings are stored here. I.e, no PASSWORDS.
	///
	////////////////////////////////////////////////////////////



//Now figure out where our libs are
switch ($_SERVER['HTTP_HOST']){
		case "127.0.0.1":
		case "192.168.2.61":
		case "pilogger.smalometern.com":
		case "cron":	
                        error_log("Server: " . $_SERVER['HTTP_HOST']);
			static $root = "/home/pi/piLogger/include/";
			static $logroot = "/home/pi/piLogger/log/";
			define("GOOGLE_ANALYTICS", 0);
			break;

		default:
                        error_log("Server: " . $_SERVER['HTTP_HOST']);
			$root = "/home/pi/piLogger/include/";
			$logroot = "/home/pi/piLogger/log/";
			define("GOOGLE_ANALYTICS", 0);
			break;

}

// Watch out, please no empty lines after closing tag
?>
