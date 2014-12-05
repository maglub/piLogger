<?php
  global $root;
  require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
  require_once($root . "myfunctions.inc");
?>
    <!-- center-pane.php -->

    <!-- Main Content Section -->
    <!-- This has been source ordered to come first in the markup (and on small devices) but to be to the right of the nav on larger screens -->
    <div class="large-10 large-push-2 small-11 small-push-1 columns">
    <!-- XXX -->
    <?php  printDbPlotConfig(); ?>
    <!-- XXX -->

<!--
       <div id="radiators-12h" style="margin: 0 auto" class="large-12 small-6 columns"></div>
       <div id="stg3" style="margin: 0 auto" class="large-12 small-12 columns"></div>
       <div id="stg3-panna" style="margin: 0 auto" class="large-12 small-12 columns"></div>
       <div id="basement-24h" style="margin: 0 auto" class="large-12 small-12 columns"></div>
       <div id="basement-168h" style="margin: 0 auto" class="large-12 small-12 columns"></div>
-->
       <div id="deviceGauges1" class="large-3 small-3 columns"></div>
       <div id="deviceGauges2" class="large-3 small-3 columns"></div>
       <div id="deviceGauges3" class="large-3 small-3 columns"></div>
       <div id="deviceGauges4" class="large-3 small-3 columns"></div>
       <div id="deviceContainer" class="large-12 small-12 columns"></div>
    </div>
