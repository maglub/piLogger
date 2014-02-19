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

function printGauge(myPane, myData){
  console.log("XXX printing gauge");

    var chart = new Highcharts.Chart({
    
        chart: {
            renderTo: myPane,
            type: 'gauge',
            plotBackgroundColor: null,
            plotBackgroundImage: null,
            plotBorderWidth: 0,
            plotShadow: false
        },
        
        title: {
            text: 'Thermometer'
        },
        
        pane: {
            startAngle: -150,
            endAngle: 150,
            background: [{
                backgroundColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                    stops: [
                        [0, '#FFF'],
                        [1, '#333']
                    ]
                },
                borderWidth: 0,
                outerRadius: '109%'
            }, {
                backgroundColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                    stops: [
                        [0, '#333'],
                        [1, '#FFF']
                    ]
                },
                borderWidth: 1,
                outerRadius: '107%'
            }, {
                // default background
            }, {
                backgroundColor: '#DDD',
                borderWidth: 0,
                outerRadius: '105%',
                innerRadius: '103%'
            }]
        },
           
        // the value axis
        yAxis: {
            min: 0,
            max: 200,
            
            minorTickInterval: 'auto',
            minorTickWidth: 1,
            minorTickLength: 10,
            minorTickPosition: 'inside',
            minorTickColor: '#666',
    
            tickPixelInterval: 30,
            tickWidth: 2,
            tickPosition: 'inside',
            tickLength: 10,
            tickColor: '#666',
            labels: {
                step: 2,
                rotation: 'auto'
            },
            title: {
                text: myData.aliases[0]
            },
            plotBands: [{
                from: 0,
                to: 120,
                color: '#55BF3B' // green
            }, {
                from: 120,
                to: 160,
                color: '#DDDF0D' // yellow
            }, {
                from: 160,
                to: 200,
                color: '#DF5353' // red
            }]        
        },
    
        series: [{
            name: myData.sensorName ,
            data: [ +(myData.temperature) ] ,
            tooltip: {
                valueSuffix: ' km/h'
            }
        }]
    
    });

  return 0;
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
