//----------------------------------------------------------
// listifyArray()
//----------------------------------------------------------
function listifyArray(myArray){
  var myString='';
  var myComma = "";

  for (var i=0;i<myArray.length;i++){
    myString += myComma + myArray[i];
    myComma=', ';
  }

  return myString;
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

    var myArray = new Array();
    myArray[0] = "apa";
    myArray[1] = "bepa";
    myArray[2] = "cepa";
  
    for (i=0; i<deviceData.length; i++) {
      var myAliasList = listifyArray(deviceData[i].aliases);
//      var myAliasList = 'apa, bepa';
      outputString += '<li>' + deviceData[i].sensorName + 
                      " -> " + deviceData[i].devicePath +
                      " -> " + myAliasList;
    }
    outputString += '</ul>';


    var target2 = document.getElementById('deviceContainer');
    target2.innerHTML = outputString;
    console.log("XXX device listing - after updating content");
}
