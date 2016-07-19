<?php
	
	//set up environment for cli
	if (!(isset($_SERVER['DOCUMENT_ROOT']) && $_SERVER['DOCUMENT_ROOT'] !== "")) {
		$_SERVER['HTTP_HOST'] = "cron";
		// add ".." to the directory name to point to "./html"
		$_SERVER['DOCUMENT_ROOT'] = __DIR__ . "/..";
		$argv = $GLOBALS['argv'];
		array_shift($GLOBALS['argv']);
		$pathInfo = $argv[0];
	}


	if(isset($ENV['debug'])) { print "apa\n"; };

	require_once($_SERVER['DOCUMENT_ROOT']."/stub.php");
	require_once($root."/../vendor/autoload.php");
	require_once($root . "myfunctions.inc.php");

	#--- instantiate Slim and SlimJson
	$app = new \Slim\Slim();

        //if run from the command-line
	if ($_SERVER['HTTP_HOST'] === "cron"){
		// Set up the environment so that Slim can route
		$app->environment = Slim\Environment::mock([
		    'PATH_INFO'   => $pathInfo
		]);
	}

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

	$isAuthenticated = true;
	#==================================
	# MAIN
	#==================================

	$app->get('/sensor', function() use ($app) {
		$res=getSensors();
		$app->render(200,o2h($res));
	});

	$app->get('/sensor/:id', function($id) use ($app) { 
		$res=getSensorById($id); 
		$app->render(200,o2h($res)); 
	}); 

	
	#--- new, proper REST for remote logging
	$app->put('/sensor/:id', function($id) use ($app){
		
		$json = $app->request()->getBody();
		$data = json_decode($json, true);

		$res = Array("ok" => false, "msg"=>"");
		
		if (isset($data['probeValue']) && isset($data['metricType'])) {
			$ret = setRRDDataBySensorId($id,$data['probeValue'], $data['metricType']);
			$res = Array("sensorId"=>$id,"temperature"=>$data['probeValue']);
			$res['ok'] = true;
			$res['msg'] = "Added temperature to the database. Return message: " . $ret;
			$retValue = 200;
		} else {
			$res['ok'] = false;
			$res['msg'] = "Error: ";
			if(!isset($data['probeValue'])) { $res .= "probeValue missing "; };
			if(!isset($data['metricType'])) { $res .= "metricType missing "; };
			$retValue = 500;
		}

		$app->render($retValue,$res);

	});

	
	$app->get('/sensor/:id/:metric', function($id,$metric) use ($app,$root) {
                $res  = ["id" => $id] + getLastDataBySensorId($id,$metric);
		$app->render(200,o2h($res));
	});
	
	$app->get('/sensor/:id/:metric/:range', function($id,$metric,$range = "") use ($app,$root) {
		$res = getDataRangeBySensorId($id,$range,$metric);
		$app->render(200,o2h($res));
	});
	
	$app->get('/sensor/all/info', function() use ($app, $root) {
		$res = getSensorInfoAll();
		$app->render(200,o2h($res));
	});

       $app->get('/alias', function() use ($app) {
               $res=getAliases();
               $app->render(200,o2h($res));
        });


	$app->get('/alias/:alias', function($alias) use ($app) {
		$res=getSensorByAlias($alias);
		$app->render(200,o2h($res));
	});
	
       $app->get('/alias/:alias/:metric/:range', function($alias,$metric,$range = "") use ($app,$root) {
                       $res = getRRDDataBySensorId(getSensorIdByAlias($alias), $range, $metric);
                       $app->render(200,o2h($res));
	});

	$app->get('/plotgroup', function() use ($app) {
		$res=getPlotgroups();
		$app->render(200,o2h($res));
	});

	$app->get('/plotgroup/:groupName', function($groupName) use ($app) {
		$res=getPlotgroupByGroupName($groupName);
		$app->render(200,o2h($res));
	});
	
	$app->run();

?>
