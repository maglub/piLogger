<?php
  require_once($root . "dbconfig.inc");
  require_once($root . "sqlite3.inc");

  db_connect();

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
    return "";
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
?>
