<?php

	require_once("./stub.php");
    require_once($root . "myfunctions.inc");

        //set up environment for cli
        if (!(isset($_SERVER['DOCUMENT_ROOT']) && $_SERVER['DOCUMENT_ROOT'] !== "")) {
                $_SERVER['HTTP_HOST'] = "cron";
                // add ".." to the directory name to point to "./html"
                $_SERVER['DOCUMENT_ROOT'] = __DIR__ . "/..";
                $argv = $GLOBALS['argv'];
                array_shift($GLOBALS['argv']);
                #$pathInfo = implode('/', $argv);
                $pathInfo = $argv[0];
        }

        require_once($root."/vendor/autoload.php");

        #--- instantiate Slim and SlimJson
        $app = new \Slim\Slim(array(
             'templates.path' => 'templates')
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


$app->get('/:route', function () use ($app) {
    $app->render('index.html', ['plotConfig' => getDbPlotConfig()]);
})->conditions(array("route" => "(|home)"));

$app->get('/graph/:graph_name', function ($graph_name) use ($app) {
    $app->render('graph.html', ['plotConfig' => Array(Array("name"=>"stg3", "timespan"=>"12h", "size"=>"6"))]);
});


$app->get('/sensors', function () use ($app) {

	$curSensors = getSensors();
	
#	foreach ($curSensors as &$curSensor){
#		$curSensor['last'] = getLastTemperatureBySensorId($curSensor['id']);
#	}

	$curLastTemperature = Array();
	foreach ($curSensors as $curSensor){
	        $curLastTemperature[$curSensor['id']] = getLastTemperatureBySensorId($curSensor['id']);
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


$app->get('/config', function () use ($app) {
    $app->render('config.html', ['plotConfig' => getDbPlotConfig(), 'sensorGroups' => getSensorGroupsAll(), 'plotGroups' => getPlotGroups()]);
});

  $app->run();

?>
