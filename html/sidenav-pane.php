<?php
  require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
  require_once($root . "myfunctions.inc");
?>
    <!-- This is source ordered to be pulled to the left on larger screens -->
    <!-- <div class="large-2 pull-10 columns"> -->
    <div class="large-2 small-12 large-pull-10 columns">
      <ul class="side-nav">
         <li class="nav-header">Temperature</li>
         <li><a href="index.html?3h">Last 3h</a></li>
         <li><a href="/graphs">Graph files</a></li>
         <li><a href="/xml">XML files</a></li>
         <li><a href="/api/sensors">Devices</a></li>
           <?php
              print "<li><ul>\n";
              $myDevices=getDevices();
              foreach ($myDevices as $device) {
                print "<li>{$device['alias']} <br>\n";
              }
              print "</ul></li>\n";
            ?>

         <li><a href="/api/sensors">Groups</a></li>

           <?php
              print "<li><ul>\n";
              $myDeviceGroups=getDeviceGroups();
              foreach ($myDeviceGroups as $deviceGroup) {
                print "<li>{$deviceGroup['name']} <br>\n";
              }
              print "</ul></li>\n";
           ?>

      </ul>
    </div>

