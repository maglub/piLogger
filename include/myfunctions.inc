<?php
  global $root;

  $vars = $_REQUEST;

  require_once($root . "dbconfig.inc");
  require_once($root . "sqlite3.inc");

  db_connect();

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

function getSensorIdByAlias($alias){
    global $db;
    $sql = "select * from alias where alias = '{$alias}';";
    $ret = $db->query($sql);
    $row = $ret->fetchArray();
	return $row['id'];
}

function getSensorByAlias($alias){
	$curId = getSensorIdByAlias($alias);
	$ret = getSensorById($curId);
	return $ret;	
}

function getSensorTemperatureDataRangeById($id, $range){
	$ret = Array(12,15,24);
	return $ret;
}

#-----------------------------------
# Aliases
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
#
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


#===========================================================
# Plot configurations
#===========================================================

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
#
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
#
#-----------------------------------

function getDbPlotConfig(){

    global $db;
    $sql = "select * from plotconfig where visible='true' order by prio;";
 
    $res = $db->query($sql);
	$curRet = Array();
	
    while ($row = $res->fetchArray() ) {
		$curRet[] = Array("name"=>$row['name'], "plotgroup"=>$row['plotgroup'], "timespan"=>$row['timespan'], "size"=>$row['size'], "prio"=>$row['prio']); 
    }
  
	return $curRet;
}

function printDbPlotConfig(){

	# XXX obsolete, can be removed soon (2015-09-18)
  global $db;
  $sql = "select * from plotconfig where visible='true' order by prio;";
 
  $ret = $db->query($sql);
  while ($row = $ret->fetchArray() ) {
    $curName = $row['name'];
    $curPlotgroup = $row['plotgroup'];
    $curTimespan = $row['timespan'];
    $curSize = $row['size'];
    $curPrio = $row['prio'];

    print<<<EOT
       <div id="{$curName}-{$curTimespan}" style="margin: 0 auto" class="large-{$curSize} small-{$curSize} columns"></div>
<script type="text/javascript">
 $(function(){
   var nothing = printGroupGraph('{$curName}-{$curTimespan}', '{$curName}', '{$curTimespan}');
 })
</script>
EOT;
  } 

  return 0;
}
#-----------------------------------
# 
#-----------------------------------
function printCenterPane(){
  require($_SERVER['DOCUMENT_ROOT'] . '/center-pane-default.php');
}

#====================================================
# Filesystem functions
#====================================================
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

#====================================================
# RRD functions
#====================================================
function getRRDDataBySensorId($curId, $timeframe="24h"){
   $curRes = rrd_fetch("/var/lib/piLogger/db/" . $curId . ".temperature.rrd", array( "AVERAGE", "--resolution", "3600", "--start", "-".$timeframe, "--end", "now" ) );
   return $curRes; 
}

function getLastRRDDataBySensorId($curId){
   $curRes = rrd_lastupdate("/var/lib/piLogger/db/" . $curId . ".temperature.rrd");
   return $curRes; 
}

function getLastTemperatureBySensorId($curId){
  $res = getLastRRDDataBySensorId($curId);
  return (float)$res['data'][0];
}

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
?>
