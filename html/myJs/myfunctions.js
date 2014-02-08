//----------------------------------------------------------
// spinnerOpts()
//----------------------------------------------------------
function getSpinnerOpts(){

  var opts = {
      lines: 13, // The number of lines to draw
      length: 20, // The length of each line
      width: 10, // The line thickness
      radius: 30, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 0, // The rotation offset
      direction: 1, // 1: clockwise, -1: counterclockwise
      color: '#000', // #rgb or #rrggbb or array of colors
      speed: 1, // Rounds per second
      trail: 60, // Afterglow percentage
      shadow: false, // Whether to render a shadow
      hwaccel: false, // Whether to use hardware acceleration
      className: 'spinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: '100', // Top position relative to parent in px
      left: 'auto' // Left position relative to parent in px
    };

  return opts;
}

function getSpinnerOptsSmall(){

  opts = {
    lines: 9, // The number of lines to draw
    length: 6, // The length of each line
    width: 6, // The line thickness
    radius: 13, // The radius of the inner circle
    corners: 1, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    direction: 1, // 1: clockwise, -1: counterclockwise
    color: '#000', // #rgb or #rrggbb or array of colors
    speed: 1, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: false, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: 'auto', // Top position relative to parent in px
    left: 'auto' // Left position relative to parent in px
  };

  return opts;
}

//----------------------------------------------------------
// draw_chart(myData)
//----------------------------------------------------------
  function draw_chart(myPane, myData){

     var plotData = [];
     var plotDataSensors = [ ];

     var plotDataArray = new Array();

     for (i=0; i<myData.length ; i++) {
       plotDataArray[i] = new Object();
       plotDataArray[i].data = myData[i].temperature.slice(0);
       plotDataArray[i].name = myData[i].sensor.slice(0);
       plotData[i] = myData[i].temperature.slice(0);
       plotDataSensors[i] = myData[i].sensor.slice(0);
     }

     var options={
          chart: {
              type: 'line',
              zoomType: 'x'
          },
          plotOptions: { line: {animation: false },
                         series: {animation: false ,
                         marker: { enabled: false } }
                       },
          title: {
              text: 'Temperatures: ' + myPane 
          },
          xAxis: {
              type: 'datetime',
              title: 'Date',
              maxZoom: 1800000
          },
          yAxis: {
              title: {
                  text: 'C'
              }
          },
                   //plotDataArray is an array [ { data: [], name: string } ]
          series:  plotDataArray

     };

     //$('#highcharts').highcharts( options );
     $('#'+myPane).highcharts( options );
  // end of function draw_chart
}

//----------------------------------------------------------
// updateDevicesPane
//----------------------------------------------------------
function updateDevicesPane(deviceData){
    /*
     * data structure for deviceData = [ { "sensorName" : "string" , "fullPath" : "string" } ]
     *
    */
    var outputString = '<ul class="side-nav"><li class="nav-header">Devices:';
  
    for (i=0; i<deviceData.length; i++) {
      outputString += '<li>' + deviceData[i].sensorName + 
                      " -> " + deviceData[i].devicePath +
                      " -> " + deviceData[i].aliases.toString() +
                      " -> " + deviceData[i].temperature;
    }
    outputString += '</ul>';

    var target2 = document.getElementById('deviceContainer');
    target2.innerHTML = outputString;
    console.log("XXX device listing - after updating content");
}

  function show(id) {
    document.getElementById(id).style.visibility = "visible";
  }
  function hide(id) {
    document.getElementById(id).style.visibility = "hidden";
  }
//----------------------------------------------------------
// printGraph(nameOfPane, numberOfHours)
//----------------------------------------------------------
function printGraph(curPane, curHours){

    var target = document.getElementById(curPane);
    var spinner = new Spinner(getSpinnerOpts()).spin(target);

    // print the graph

    //var url="api/sensorData";
    var url="cache/sensorData." + curHours.toString() + ".json";

   console.log("XXX graph data url: " + url);
    $.ajax({
      url: url,
      type: 'GET',
      dataType: "json",
      success: function(data) {
        draw_chart(curPane, data);
          console.log("XXX Stopping spinner");
          spinner.stop();
      },
      error: function(data) {
          spinner.stop();
          var target2 = document.getElementById(curPane);
          target2.innerHTML = 'Error: could not load data for graph';
      }
    //end of ajax
    });

   return 0;

}
