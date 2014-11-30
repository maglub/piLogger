<?php
   class MyDB extends SQLite3
   {
      function __construct()
      {
         global $db_target;
         $this->open($db_target);
      }
   }

function db_connect() {
  global $is_connected, $db;

  if(!$is_connected) {

    $db = new MyDB();

    if(!$db){
      echo $db->lastErrorMsg();
    }

    $is_connected = 1;
  }
}

?>
