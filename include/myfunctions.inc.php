<?php
  global $root;

  $vars = $_REQUEST;

  require_once($root . "dbconfig.inc.php");
  require_once($root . "sqlite3.inc.php");

  db_connect();

#-----------------------------------
# getAppConfig()
#-----------------------------------
function authenticate($username, $password){
	if (genPasswordHash($password) == getAdminPassword()){
		return true;
	} else {
		return false;
	}
}

function isAuthenticated(){
	if (isset($_SESSION['username']) && $_SESSION['username'] == "admin"){
		return true;
	} else {
		return false;
	}
}

#-----------------------------------
# getSensorGroups()
#-----------------------------------
function getAdminPassword(){
  global $db;

  $sql = "select password from passwd where username = 'admin'";
  $stmt = $db->prepare($sql);

  $ret = $stmt->execute();

  if($row = $ret->fetchArray()){
    $password = $row['password']; 
  }
  
  return $password;
}

function setPassword($username, $password){
	global $db;
	
	$hash = genPasswordHash($password);
	$sql = "update passwd set password = '{$hash}' where username = '{$username}'";
    $stmt = $db->prepare($sql);
    $ret = $stmt->execute();

	return 0;
}

function addUser($uid,$username){
	global $db;
	
	$sql = "insert into passwd values ({$uid},'{$username}','')";
    $stmt = $db->prepare($sql);
    $ret = $stmt->execute();

	return 0;
}

function deleteUser($username){
	global $db;
	
	$sql = "delete from passwd where username = '{$username}'";
    $stmt = $db->prepare($sql);
    $ret = $stmt->execute();

	return 0;
	
}

function genPasswordHash($password){
	$hash = crypt( $password , 'piLogger' );
	return $hash;
}

function dropPasswdTable(){
	global $db;
	
	$sql = "drop table if exists passwd";
    $stmt = $db->prepare($sql);
    $ret = $stmt->execute();
	
	return 0;
}

function createPasswdTable(){
	global $db;
	
	$sql = "create table if not exists passwd(uid integer, username string, password string);";
    $stmt = $db->prepare($sql);
    $ret = $stmt->execute();

	return 0;
}

#-----------------------------------
# getAppConfig()
#-----------------------------------
function getAppConfig($configFile){
	#--- from http://inthebox.webmin.com/one-config-file-to-rule-them-all
	$file=$configFile;
	$lines = file($file);
	$config = array();
 
	foreach ($lines as $line_num=>$line) {
	  # Comment?
	  if ( ! preg_match("/#.*/", $line) ) {
	    # Contains non-whitespace?
	    if ( preg_match("/\S/", $line) ) {
	      list( $key, $value ) = str_replace('"','',explode( "=", trim( $line ), 2));
	      $config[$key] = $value;
	    }
	  }
	}
 
	// Print it out
	#print_r($config);
	return $config;
}

#-----------------------------------
# getSensorGroups()
#-----------------------------------
function getSensorGroups(){

  global $db;
  $retArray = array();
  $sql = "select distinct groupname from sensorgroup;";

  $ret = $db->query($sql);
  while($row = $ret->fetchArray()){
    $retArray[] = Array ('name' => $row['groupname']); 
  }
  return $retArray;
}

#-----------------------------------
# getSensorGroupMembers() 
#-----------------------------------
function getSensorGroupMembers($sensorGroup){

    global $db;
    $retArray = array();
    $sql = "select sensor_id from sensorgroup where groupname = '{$sensorGroup}';";

    $ret = $db->query($sql);
    while($row = $ret->fetchArray()){
      $retArray[] = Array('sensor_id' => $row['sensor_id']) ; 
    }
    return $retArray;
	
}

#-----------------------------------
# getSensorGroupsAll()
#-----------------------------------
function getSensorGroupsAll(){
    global $db;

	$retArray = getSensorGroups();

	foreach($retArray as &$curSensorGroup){
	    $curSensorGroup['members'] = getSensorGroupMembers($curSensorGroup['name']);	
	}

  return $retArray;
}

#-----------------------------------
# getSensors()
#-----------------------------------
function getSensors(){
  global $db;
  $sql = "select * from sensor;";

  $n = 0;
  $ret = $db->query($sql);
  $retArray = [];
  while($row = $ret->fetchArray()){
    $retArray[] = Array('id' => $row['id'], 'alias' => getSensorAliasById($row['id']),'type' => $row['type']);
  }
  return $retArray;
}

#-----------------------------------
# getSensorById()
#-----------------------------------
function getSensorById($id){
	
    global $db;


    $sql = "select * from sensor where id = '{$id}' limit 1;";

    $n = 0;
    $ret = $db->query($sql);

    $retArray = null;
    while ($row = $ret->fetchArray()) {
	$retArray['id'] = $row['id'];
	$retArray['type'] = $row['type'];
	$retArray['path'] = $row['path'];	 
	$retArray['alias'] = Array(getSensorAliasById($row['id']));
    } 

    return $retArray;
}

#-----------------------------------
# getSensorIdByAlias()
#-----------------------------------
function getSensorIdByAlias($alias){
    global $db;
    $sql = "select * from alias where alias = '{$alias}';";
    $ret = $db->query($sql);
    $row = $ret->fetchArray();
	return $row['id'];
}

#-----------------------------------
# getSensorByAlias()
#-----------------------------------
function getSensorByAlias($alias){
	$curId = getSensorIdByAlias($alias);
	$ret = getSensorById($curId);
	return $ret;	
}

#-----------------------------------
# getSensorTemperatureDataRangeById()
#-----------------------------------
function getSensorTemperatureDataRangeById($id, $range){
	$ret = Array(12,15,24);
	return $ret;
}

#-----------------------------------
# getAliases()
#-----------------------------------
function getAliases(){
    global $db;
    $sql = "select alias, id from alias;";
    $ret = $db->query($sql);

       $retArray = [];
    while($row = $ret->fetchArray()){
      $retArray[] = Array($row['alias'] => $row['id']) ; 
    }
       return $retArray;
}

#-----------------------------------
# getSensorAliasById()
#-----------------------------------
function getSensorAliasById($curId){
  global $db;
  $sql = "select alias from alias where id = '{$curId}';";
 
  $ret = $db->query($sql);
  if ($row = $ret->fetchArray() ) {
    return $row['alias'];
  } else {
    return $curId;
  }
}

#-----------------------------------
# getDeviceStores()
#-----------------------------------
function getDeviceStores(){
  global $db_dir;
  $files = scandir($db_dir);

  $cur_dbFiles = array();

  $i = 0;
  foreach ($files as $cur_file) {
    if ( is_file($db_dir . "/" . $cur_file ) && preg_match('/\.rrd$/', $cur_file)) {
      $cur_dbFiles[$i] = $cur_file;
      $i++;
    }
  }

  return $cur_dbFiles;
}

#-----------------------------------
# getPlotgroups()
#-----------------------------------
function getPlotgroups(){
    global $db;
    $sql = "select distinct(groupname) from plotgroup;";
 
    $ret = $db->query($sql);
	$n = 0;
    while($row = $ret->fetchArray()){
      $retArray[] = getPlotGroupByGroupName($row['groupname']);

      $n++;
    }
    return $retArray;	
}

#-----------------------------------
# getPlotGroupByGroupName()
#-----------------------------------
function getPlotGroupByGroupName($groupName){
    global $db;
    $sql = "select * from plotgroup where groupname = '{$groupName}';";

    $ret = $db->query($sql);
        $retArray = [];
        $retArray['groupname'] = $groupName;
		$retMembers = Array();
    while($row = $ret->fetchArray()){
                $retMembers[] = Array('sensor_id' => $row['sensor_id'], 'plot_type' => $row['plot_type'], 'plot_metric' => "temperature");
    }

        $retArray['members'] = $retMembers;
    return $retArray;

}

#-----------------------------------
# getAggregateTypeByPlotDeviceId()
#-----------------------------------
function getAggregateTypeByPlotDeviceId($curPlotType, $curId){
  global $db;
  $sql = "select plot_type from plotgroup where groupname = '{$curPlotType} and sensor_id = '{$curId}';";
 
  $ret = $db->query($sql);
  if ($row = $ret->fetchArray() ) {
    return $row['alias'];
  } else {
    return "AVERAGE";
  }
  return $retArray;
}

#-----------------------------------
# getDbPlotConfig()
#-----------------------------------
function getDbPlotConfig($plotGroup = "%"){

    global $db;
    $sql = "select * from plotconfig where visible='true' and name like '{$plotGroup}' order by prio;";
 
    $res = $db->query($sql);
	$curRet = Array();
	
    while ($row = $res->fetchArray() ) {
		$curRet[] = Array("dashboard"=>$row['name'], "plotgroup"=>$row['plotgroup'], "timespan"=>$row['timespan'], "size"=>$row['size'], "prio"=>$row['prio']); 
    }
  
	return $curRet;
}

#-----------------------------------
# getSensorIdFromFilesystem()
#-----------------------------------
function getSensorIdFromFilesystem($options = array() ){

  if (isset($options['forceScan'])&& $options['forceScan']){
    $sensorDir = "/mnt/1wire/uncached";
  } else {
    $sensorDir = "/mnt/1wire";
  }

  $curRes = scandir($sensorDir);

  $curRet = [] ;
  foreach ($curRes as $curFile) {
    if (is_dir($sensorDir . "/" . $curFile) && preg_match('/^-?[0-9]+$/', $curFile[0]) ) {
      $curRet[] = array("id"=>$curFile);
    }

  }

  return $curRet;
}

#-----------------------------------
# createRRDDataBySensorId()
#-----------------------------------
function createRRDDatabaseBySensorId($curId, $metricType = "temperature"){
	global $root;
	$resOs = shell_exec("${root}/../bin/createRRD $curId $metricType 2>&1");
	
	return 0;
}

#-----------------------------------
# setRRDDataBySensorId()
#-----------------------------------
function setRRDDataBySensorId($curId, $metricValue, $metricType = "temperature"){
	if (!file_exists("/var/lib/piLogger/db/" . $curId . "." . $metricType . ".rrd")){
		createRRDDatabaseBySensorId($curId, $metricType);
	}
	
   $curRes = rrd_update("/var/lib/piLogger/db/" . $curId . "." . $metricType . ".rrd", array( "N:" . $metricValue ) );

   if($curRes == 0 ) {
	   $err = rrd_error();
	   $curRes = "Error: {$err}\n";
   } else {
	   $curRes = "OK!";
   }

   return $curRes; 

}


#-----------------------------------
# getRRDDataBySensorId()
#-----------------------------------
function getRRDDataBySensorId($curId, $timeframe="24h"){
   $curRes = rrd_fetch("/var/lib/piLogger/db/" . $curId . ".temperature.rrd", array( "AVERAGE", "--resolution", "3600", "--start", "-".$timeframe, "--end", "now" ) );
   return $curRes; 
}

#-----------------------------------
# getLastRRDDataBySensorId()
#-----------------------------------
function getLastRRDDataBySensorId($curId){
   $curRes = rrd_lastupdate("/var/lib/piLogger/db/" . $curId . ".temperature.rrd");
   return $curRes; 
}

#-----------------------------------
# getLastTemperatureBySensorId()
#-----------------------------------
function getLastTemperatureBySensorId($curId){
  $res = getLastRRDDataBySensorId($curId);
  return Array("timestamp" => $res['last_update'], "temperature" => (float)$res['data'][0]);
}

#-----------------------------------
# getSensorInfoAll()
#-----------------------------------
function getSensorInfoAll(){
  $res = getSensors();
  foreach ($res as &$curRes) {
    $curRes['temperature'] = getLastTemperatureBySensorId($curRes['id']);
    $curRes['devicePath'] = $curRes['id'];
    $curRes['sensorName'] = $curRes['id'];
    $curRes['aliases'] = array($curRes['alias']);
  }
  return $res;
}

#-----------------------------------
# printSparklineByDeviceId()
#-----------------------------------
function printSparklineByDeviceId($curId, $timeframe = "12h"){
  $curRes = getRRDDataBySensorId($curId, $timeframe);

  $n = 0;
  $ret="";
  foreach($curRes['data']['temperature'] as $ts => $value){
    if(!is_nan($value)){
      $ret .= (($n > 0)?",".$value: $value);
      $n+=1;
    }
  }

  return $ret;
}

#-----------------------------------
# getTemperatureRangeBySensorId()
#-----------------------------------
function getTemperatureRangeBySensorId($curId, $timeframe = "12h"){
  $curRes = getRRDDataBySensorId($curId, $timeframe);
  $ret = array();

  $ret['sensor'] = $curId;
  $ret['temperature'] = array();

  foreach($curRes['data']['temperature'] as $ts => $value){
    if(!is_nan($value)){
      $ret['temperature'][] = array( $ts *1000 ,(float)$value);
    }
  }

  return $ret; 
}

#-----------------------------------
# getListOfInstalledPlugins()
#-----------------------------------
function getListOfInstalledPlugins(){
	global $root;
  	return array_diff(scandir($root . '/../remote-logging.d'), array('..', '.'));   
}


#-----------------------------------
# getListOfActivePlugins()
#-----------------------------------
function getListOfActivePlugins(){

  return array_diff(scandir('/var/lib/piLogger/remote-logging-enabled/'), array('..', '.')); 

}

#-----------------------------------
# getPluginInfos()
#-----------------------------------
function getPluginInfos(){

  // initialize empty info array
  $info = array();

  // define the info for piLogger-clud plugin
  $files = exec('ls -f /var/spool/piLogger/ | wc -l ') -2;
  $info['piLogger-cloud'] = $files.' files in spool directory';

  // define the info for piLogger-remote plugin
  $info['piLgger-remote'] = '';

  // define the info for shiftr.io plugin
  $info['shiftr.io'] = '';

  // return the array
  return $info;

}
?>
