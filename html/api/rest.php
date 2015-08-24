<?php
	#--- go to xyz/includes (which has composer.phar and composer.json)
	#--- run ./composer.phar install
	#
	#--- the .htaccess file in the ./api directory can look like this:
	#
	#--- maglub@ubuntu-14:~/dev/web/public_html/api$ cat .htaccess 
	#--- RewriteEngine on
	#--- RewriteCond %{REQUEST_FILENAME} !-f
	#--- RewriteRule ^ /api/rest.php [QSA,L]
	
	
	#--- default Nordiska config
	require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
	require_once($root."/vendor/autoload.php");

    require_once($root . "myfunctions.inc");

 
    //db_connect();
	
	#--- this is a workaround, so that json_encode in SlimJson works
	#--- since our database is iso-latin-1
	#--- we can remove this as soon as we have migrated our database
	//mysql_set_charset("utf8");
	
	#--- instantiate Slim and SlimJson
	$app = new \Slim\Slim();
    $app->add(new \SlimJson\Middleware());
	

	#======== helper functions
	function o2h($obj){ #--- object to hash helper function (since json_encode cannot serialize php objects)
		$ret = Array();
		foreach($obj as $key => &$field){
			if(is_object($field)){
				$field = o2h($field);
			}
			$ret[$key] = $field;
		}
		return $ret;
	}

	//$isAuthenticated = checkMySession(CONST_TRIAL);
	$isAuthenticated = true;
	#==================================
	# MAIN
	#==================================

	$app->get('/sensor', function() use ($app) {
		$res=getDevices();
		$app->render(200,o2h($res));
	}//end of function
	);

	$app->get('/sensor/:id', function($id) use ($app) {
		$res=getSensorById($id);
		$app->render(200,o2h($res));
	}//end of function
	);

	#--- ugly workaround to break-fix remote logging (see #71)
	$app->get('/sensor/:id/set/temperature/:temperature', function($id, $temperature) use ($app,$root) {
		$resOs = shell_exec("${root}/../bin/logTemperature $id $temperature 2>&1");
		//print "{\"result\":\"ok\", \"command\":\"${root}/../bin/logTemperature $id $temperature\",\"message\":\"{$resOs}\"}";
		print "{\"result\":\"ok\"}";
	}//end of function
	);
	
	
	$app->get('/sensor/all/info', function() use ($app, $root) {
		$resOs = shell_exec($root . "/../bin/listDevices --json --info");
		// the output is already in json format
		print $resOs;
//		$res=getDevices();
//		$app->render(200,o2h($res));
	}//end of function
	);

	$app->get('/alias/:alias', function($alias) use ($app) {
		$res=getSensorByAlias($alias);
		$app->render(200,o2h($res));
	}//end of function
	);
	
	$app->get('/plotgroup', function() use ($app) {
		$res=getPlotgroups();
		$app->render(200,o2h($res));
	}//end of function
	);

	$app->get('/plotgroup/:groupName', function($groupName) use ($app) {
		$res=getPlotgroupByGroupName($groupName);
		$app->render(200,o2h($res));
	}//end of function
	);
	



	
	
	
	$app->run();

?>