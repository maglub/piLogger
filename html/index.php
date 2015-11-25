<?php
	session_start();

        //set up environment for cli
        if (!(isset($_SERVER['DOCUMENT_ROOT']) && $_SERVER['DOCUMENT_ROOT'] !== "")) {
                $_SERVER['HTTP_HOST'] = "cron";
                // add ".." to the directory name to point to "./html"
                $_SERVER['DOCUMENT_ROOT'] = __DIR__ . "/..";
                $argv = $GLOBALS['argv'];
                array_shift($GLOBALS['argv']);
                $pathInfo = $argv[0];
        }

	require_once("./stub.php");

	require_once($root . "myfunctions.inc.php");
	require_once($root."/../vendor/autoload.php");
	$config = getAppConfig($root . "/../etc/piLogger.conf");

        #--- instantiate Slim and SlimJson
        $app = new \Slim\Slim(array(
             'templates.path' => $root . '/templates')
        );

        //if run from the command-line
        if ($_SERVER['HTTP_HOST'] === "cron"){
                // Set up the environment so that Slim can route
                $app->environment = Slim\Environment::mock([
                    'PATH_INFO'   => $pathInfo
                ]);
        }


// define the engine used for the view
$app->view(new \Slim\Views\Twig());

// configure Twig template engine
$app->view->parserOptions = array(
   'charset' => 'utf-8',
   'cache' => realpath('templates/cache'),
   'auto_reload' => true,
   'strict_variables' => false,
   'autoescape' => true
);

$app->view->parserExtensions = array(new \Slim\Views\TwigExtension());

$twig = $app->view()->getEnvironment();
$twig->addGlobal('devicename', gethostname());
$twig->addGlobal('isOffline', (isset($config['isOffline']) && $config['isOffline'] == "true")?true:false);
$twig->addGlobal('config', $config);
$twig->addGlobal('isAuthenticated', isAuthenticated());

#===================================================
# Main
#===================================================

$app->get('/:route', function () use ($app) {
    $app->render('index.html', ['plotConfig' => getDbPlotConfig(),'activePlugins' => getListOfActivePlugins()]);
})->conditions(array("route" => "(|home)"));

$app->get('/graph/:config_name', function ($config_name) use ($app) {
    $app->render('graph.html', ['plotConfig' => getDbPlotConfig($config_name)]);
});

$app->get('/graph/:plotgroup/:timespan', function ($plotgroup, $timespan, $size = 12) use ($app) {
   $app->render('graph.html', ['plotConfig' => Array(Array("name"=>"{$plotgroup}", "timespan"=>"{$timespan}", "size"=> $size))]);
});


$app->get('/sensors', function () use ($app) {

	$curSensors = getSensors();

	$curLastTemperature = Array();
	foreach ($curSensors as $curSensor){
	        $curLastTemperature[$curSensor['id']] = getLastTemperatureBySensorId($curSensor['id']);
	        $curLastTemperature[$curSensor['id']]['datestamp'] = date('Y-m-d G:i:s T',$curLastTemperature[$curSensor['id']]['timestamp']);
	}
	
	$curSparklines = Array();

	foreach ($curSensors as $curSensor){
		$curSparklines[$curSensor['id']] = printSparklineByDeviceId($curSensor['id']);
	}
	
	
    $newSensors = [];

	foreach (getSensorIdFromFilesystem( array('forceScan'=>true) ) as $curSensorFile){
		$curSensor = getSensorById($curSensorFile['id']);

		if (!$curSensor){
			$newSensors[] = $curSensorFile;
		}
	}
	
    $app->render('sensors.html', ['sensors' => $curSensors, 'sparklines' => $curSparklines , 'nonRegisteredFiles' => $newSensors, 'lastTemperature' => $curLastTemperature]);
});

$app->get('/sensor/:sensorId', function ($sensorId) use ($app) {
	$curSensor = getSensorById($sensorId);
	$curSensor += getLastTemperatureBySensorId($sensorId);
        $curSensor['datestamp'] = date('Y-m-d G:i:s T',$curSensor['timestamp']);
	$curSensor['sparkline'] = printSparklineByDeviceId($sensorId);
	
   $app->render('sensor.html', [ 'sensor' => $curSensor ]);
});


#=============================================================
# /config
#=============================================================
$app->map('/config', function () use ($app,$root) {
  if ($app->request()->isPost()) {
    $action = $app->request->post('actionCrontab');
    switch ($action) {
      case "Disable":
        $res = shell_exec("sudo -u pi ${root}/../bin/wrapper disableCrontab > /dev/null 2>&1");
        break;

      case "Enable":
        $res = shell_exec("sudo -u pi ${root}/../bin/wrapper enableCrontab > /dev/null 2>&1");
        break;

    }
    $app->redirect('/config');
  }



    $crontab = shell_exec("sudo -u pi ${root}/../bin/wrapper getCrontab 2>/dev/null");

    $app->render('config.html', ['plotConfig' => getDbPlotConfig(), 'sensorGroups' => getSensorGroupsAll(), 'plotGroups' => getPlotGroups(), 'installedPlugins' => getListOfInstalledPlugins(), 'activePlugins' => getListOfActivePlugins(), 'plugininfo' => getPluginInfos(), "crontab" => $crontab ]);
})->via('GET', 'POST')->name('config');

#=============================================================
# /login
#=============================================================
$app->map('/login', function () use ($app) {

    $username = null;

    if ($app->request()->isPost()) {
        $username = "admin";
        $password = $app->request->post('password');

		$result = authenticate($username, $password);
        #$result = $app->authenticator->authenticate($username, $password);

        if ($result) {
			$_SESSION["username"] = "admin";
			$_SESSION["role"] = "admin";
            $app->redirect('/');
        } else {
            $messages = "Wrong password";
            $app->flashNow('error', $messages);
        }
    }

    $app->render('login.html', []);
})->via('GET', 'POST')->name('login');

$app->get('/logout', function() use ($app){
	$_SESSION = array();
	session_destroy();
    $app->redirect('/');
	
});

  $app->run();

?>
