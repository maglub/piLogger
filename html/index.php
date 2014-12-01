<?php
  require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
  require_once($root . "myfunctions.inc");

?>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>piLogger</title>

    <!--
    <link rel="shortcut icon" href="http://pilogger.smalometern.com/favicon.ico" type="image/vnd.microsoft.icon"/>
    <link rel="icon" href="http://pilogger.smalometern.com/favicon.ico" type="image/x-ico"/>
    -->

    <link rel="shortcut icon" href="/favicon.ico" >
    <link rel="icon" href="/favicon.ico" >

    <link rel="stylesheet" href="css/normalize.css">
    <link rel="stylesheet" href="css/foundation.css">
    <link href="http://fonts.googleapis.com/css?family=Corben:bold" rel="stylesheet" type="text/css">
    <link href="http://fonts.googleapis.com/css?family=Nobile" rel="stylesheet" type="text/css">

    <script src="http://fgnass.github.io/spin.js/spin.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script src="http://code.highcharts.com/highcharts.js"></script>
    <script src="http://code.highcharts.com/highcharts-more.js"></script>
    <script src="http://code.highcharts.com/modules/exporting.js"></script>

    <link rel="stylesheet" href="css/main.css">
  
    <script src="myJs/myfunctions.js"></script>
    <script src="js/foundation/foundation.js"></script>
    <script src="js/foundation/foundation.dropdown.js"></script>

  <!-- http://www.highcharts.com/docs/getting-started/your-first-chart -->
<script type="text/javascript">
   console.log("XXX Here it starts");

  $(function(){
/*
    var target = document.getElementById('highcharts');
    var spinner = new Spinner(getSpinnerOpts()).spin(target);

    // print the graph

    var url="api/sensorData";
    //var url="cache/sensorData.json";
    console.log("XXX graph data url: " + url);

    $.ajax({
      url: url,
      type: 'GET',
      dataType: "json",
      success: function(data) {
        draw_chart(data);
          console.log("XXX Stopping spinner");
          spinner.stop();
      },
      error: function(data) {
          spinner.stop();
          var target2 = document.getElementById('highcharts');
          target2.innerHTML = 'Error: could not load data for graph';
      }
    //end of ajax
    });

*/

   var nothing = printGroupGraph('radiators-12h', 'radiators', '12h');
   var nothing = printGroupGraph('stg3', 'stg3', '12h');
   var nothing = printGroupGraph('basement-12h', 'basement', '12h');
   var nothing = printGraph('piLogger24h', '24h');
   var nothing = printGraph('piLogger168h', '168h');

   console.log("XXX End of graph");

  //========================================
  // Devices
  //========================================
    console.log("XXX Start of device listing");

    var target = document.getElementById('deviceContainer');
    var dp = document.getElementById('device-pane');
    var spinner2 = new Spinner(getSpinnerOptsSmall()).spin(target);

    // print the devices into the devicesContainer
   var url="api/sensor/all/info";
   //var url="cache/sensorAllInfo.json";
   console.log("XXX url: " + url);

    $.ajax({
      url: url,
      type: 'GET',
      dataType: "json",
      success: function(data) {
        updateDevicesPane(data);
        var nothing = printGauge('deviceGauges1', data[0] ); 
        var nothing = printGauge('deviceGauges2', data[1] ); 
        var nothing = printGauge('deviceGauges3', data[2] ); 
        var nothing = printGauge('deviceGauges4', data[3] ); 
//        dp.innerHTML = 'Device: ' + data[0].sensorName;
        spinner2.stop();
      },
      error: function(data) {
        spinner2.stop();
        var target2 = document.getElementById('deviceContainer');
        target2.innerHTML = 'Error: could not load data for devices';
      }
    //end of ajax
    });


//  var curData = { "sensorName" : "device1" , "temperature" : 80 };
//  var nothing = printGauge('deviceGauges', curData ); 

  console.log("XXX End of jquery block");
});

   console.log("XXX Here it ends");
</script>
  </head>
  <body>

    <!-- ============================================================ -->
    <!-- Header and Nav                                               -->
    <!-- ============================================================ -->
    <?php require('header-pane.php'); ?>

    <!-- ============================================================ -->
    <!-- Main row (contains center/graphs, and side navigation        -->
    <!-- ============================================================ -->
  <div class="row">
    <!-- ============================================================ -->
    <!-- Center / Graphs                                              -->
    <!-- ============================================================ -->
    <?php  require('center-pane.php'); ?>

    <!-- ============================================================ -->
    <!-- Side Navigation bar                                          -->
    <!-- ============================================================ -->
    <!-- This is source ordered to be pulled to the left on larger screens -->
    <?php  require('sidenav-pane.php'); ?>

  </div>
  </div>
  <!-- end of main row -->

    <!-- ============================================================ -->
    <!-- Footer pane                                                  -->
    <!-- ============================================================ -->
    <?php require('footer-pane.php') ?>

<script>
  $(document).foundation();
</script>
  </body>
</html>
