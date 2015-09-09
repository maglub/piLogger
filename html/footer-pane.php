<?php
  require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
  require_once($root . "myfunctions.inc");
?>

  <!-- footer-pane.php -->
  <footer class="row">
    <div class="large-12 columns">
      <hr />
      <div class="row">
        <div class="large-6 columns">
          <p>&copy; KMG Group GmbH</p>
        </div>
        <div class="large-6 columns">

        </div>
      </div>
    </div>
  </footer>

<script>
</script>

<?php

  #--- if /?debug=true -> print some useful info in the footer
  if ( isset($vars['debug']) && $vars['debug'] != "" ) {
    print "<h2>Devices</h2>\n";
    print "<ul>\n";
    $myDevices=getDevices();
    foreach ($myDevices as $device) {
      print "<li> {$device['id']} - {$device['alias']} <br>\n";
    }
    print "</ul>\n";
  
    print "<h2>DB Files</h2>\n";
    print "<ul>\n";
    $myDbFiles = getDeviceStores();
    foreach ($myDbFiles as $dbFile) {
      preg_match('/^(.*)(\.rrd)/i', $dbFile, $cur_id);
      print "<li> {$dbFile} - Device: {$cur_id[1]} Alias: " . getDeviceAliasById($cur_id[1]) . "<br>\n";
    }
    print "</ul>\n";
  }


?>
