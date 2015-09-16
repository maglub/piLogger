<?php
  require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
  require_once($root . "myfunctions.inc");
?>

<!-- Header and Nav -->
  <div class="row">
    <div class="large-2 small-2 columns">
      <h1><a href="/"><img src="/images/rpi-logo.png" alt="RPi logo"></a></h1>
    </div>
    <div class="large-10 small-10 columns">
      <ul class="inline-list right">
         <li><a href="#" data-dropdown="left-pane-devices" aria-controls="left-pane-devices" aria-expanded="false">Devices</a>

         <ul id="left-pane-devices" class="f-dropdown" data-dropdown-content aria-hidden="true" tabindex="-1">
           <?php
              $mySensors=getSensors();
              foreach ($mySensors as $sensor) {
                print "<li>{$sensor['alias']} <br>\n";
              }
            ?>
         </ul>

         <li><a href="#" data-dropdown="left-pane-devicegroups" aria-controls="left-pane-devicegroups" aria-expanded="false">Groups</a>

         <ul id="left-pane-devicegroups" class="f-dropdown" data-dropdown-content aria-hidden="true" tabindex="-1">
           <?php
              $mySensorGroups=getSensorGroups();
              foreach ($mySensorGroups as $sensorGroup) {
                print "<li>{$sensorGroup['name']} <br>\n";
              }
           ?>
         </ul>

        <li><a href="https://github.com/maglub/piLogger">About</a></li>
      </ul>
    </div>
  </div>

