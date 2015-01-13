<?php
  global $root;
  require_once($root . "dbconfig.inc");
  require_once($root . "sqlite3.inc");

  db_connect();

#-----------------------------------
# getDeviceGroups()
#-----------------------------------
function getDeviceGroups(){

  global $db;
  $retArray = array();
  $sql = "select distinct groupname from devicegroup;";

  $n = 0;
  $ret = $db->query($sql);
  while($row = $ret->fetchArray()){
    $retArray[$n]['name'] = $row['groupname'] ; 
    $n++;
  }
  return $retArray;
}

#-----------------------------------
# getDevices()
#-----------------------------------
function getDevices(){

  global $db;
  $sql = "select * from device;";

  $n = 0;
  $ret = $db->query($sql);
  while($row = $ret->fetchArray()){
    $retArray[$n]['id'] = $row['id'] ; 
    $retArray[$n]['alias'] = getDeviceAliasById($row['id']);
    $n++;
  }
  return $retArray;
}

#-----------------------------------
#
#-----------------------------------
function getDeviceAliasById($curId){
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
#-----------------------------------
#
#-----------------------------------
function getAggregateTypeByPlotDeviceId($curPlotType, $curId){
  global $db;
  $sql = "select plot_type from plotgroup where groupname = '{$curPlotType} and device_id = '{$curId}';";
 
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
function printDbPlotConfig(){

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
  require($_SERVER['DOCUMENT_ROOT'] . '/center-pane.php');
}
?>
