function updatepage( juliafun, fundata, filespayload ) {
  var xhttp = new XMLHttpRequest();
  
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var payload = JSON.parse( xhttp.responseText );
      parse_response( payload );
    }
  };

  var formdata = new FormData();

  for (key in fundata)
    formdata.set( key, fundata[key] );

  if ((filespayload != null) && (filespayload.length == 1))
    formdata.set( 'file', filespayload[0] );

  xhttp.open( "POST", "op/" + juliafun, true );
  xhttp.send( formdata );
}


function update( updatetype, juliafun, fundata ) {
  Genie.WebChannels.sendMessageTo( updatetype, juliafun, fundata );
}


function updateoverws( ws, payload={} ) {
  ws.send( JSON.stringify(payload) );
}


function updateoverwsroute( wsroute, payload ) {
  ws.send( JSON.stringify( {"wsroute": wsroute, "payload": payload} ) );
}


window.parse_payload = function ( payload ) {
  if (typeof payload === "object")
    parse_response(payload);
  else
    console.log( payload + "  (" + (typeof payload) + ")" );
}

function parse_response( payload ) {
  for (tag in payload) {
    var responseData = payload[tag];
    var docel = document.getElementById( tag );

    for (ttag in responseData) {
      if (ttag == 'data') {
        if (responseData.type == 1)
          docel.innerHTML = responseData[ttag];
        else if (responseData.type == 0)
          docel.innerHTML += responseData[ttag];
        else
          docel.remove(); 
      }
      else if ((ttag == 'style') && ('object' == typeof responseData['style'])) {
        styleData = responseData['style'];

        for (stag in styleData) {
          iind = -1;

          if (typeof styleData[stag] == "string") {
            sdata = styleData[stag].trim();
            iind = sdata.indexOf( '!important' );
          }

          if (iind == -1)
            docel.style.setProperty( stag, styleData[stag] );
          else
            docel.style.setProperty( stag, sdata.substr( 0, iind ), 'important' );
        }
      }
      else if ((ttag == 'class') && ('object' == typeof responseData['class'])) {
        classData = responseData['class'];

        for (ctag in classData) {
          if (classData[ctag])
            docel.classList.add(ctag);
          else {
            docel.classList.remove(ctag);
          }
        }
      }
      else if (ttag != 'type')
        if (responseData[ttag] == null)
          docel.removeAttribute( ttag );
        else
          docel.setAttribute( ttag, responseData[ttag] );
    }
  }
}
