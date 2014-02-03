function updateDevicesPane(deviceData){
    /*
     * data structure for deviceData = [ { "sensorName" : "string" , "fullPath" : "string" } ]
     *
    */
    var outputString = '<ul class="side-nav"><li class="nav-header">Devices:';

    for (i=0; i<deviceData.length; i++) {
      outputString += '<li>' + deviceData[i].sensorName + " -> " + deviceData[i].devicePath;
    }
    outputString += '</ul>';
    var target2 = document.getElementById('deviceContainer');
    target2.innerHTML = outputString;
    console.log("XXX device listing - after updating content");
}
