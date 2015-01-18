<!DOCTYPE HTML>
<?php
  require_once($_SERVER['DOCUMENT_ROOT']."/stub.inc");
  require_once($root . "myfunctions.inc");

?>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>piLogger</title>

    <link rel="shortcut icon" href="/favicon.ico" >
    <link rel="icon" href="/favicon.ico" >

    <link rel="stylesheet" type="text/css" href="css/normalize.css">
    <link rel="stylesheet" type="text/css" href="css/foundation.css">
    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Corben:bold">
    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Nobile" >
	<link rel="stylesheet" type="text/css" href="css/main.css">

    <script type="text/javascript" src="http://fgnass.github.io/spin.js/spin.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://code.highcharts.com/highcharts.js"></script>
    <script type="text/javascript" src="http://code.highcharts.com/highcharts-more.js"></script>
    <script type="text/javascript" src="http://code.highcharts.com/modules/exporting.js"></script>

    <script type="text/javascript" src="myJs/myfunctions.js"></script>
    <script type="text/javascript" src="js/foundation/foundation.js"></script>
    <script type="text/javascript" src="js/foundation/foundation.dropdown.js"></script>
    
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
    <?php  printCenterPane(); ?>

    <!-- ============================================================ -->
    <!-- Side Navigation bar                                          -->
    <!-- ============================================================ -->
    <!-- This is source ordered to be pulled to the left on larger screens -->
    <?php  require('sidenav-pane.php'); ?>

    </div>
  <!-- end of main row -->

    <!-- ============================================================ -->
    <!-- Footer pane                                                  -->
    <!-- ============================================================ -->
    <?php require('footer-pane.php') ?>

  <script>$(document).foundation();</script>
  </body>
</html>
