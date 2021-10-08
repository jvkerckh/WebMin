export callHMAlert!, halfmoon


function callHMAlert!( msg::Dict{String,Dict{String,Any}},
    hmid::AbstractString, isJS::Bool=true, timeinms::Integer=5000 )
    hmalert = Dict("hmid" => hmid)
    isJS || (hmalert["time"] = timeinms)
    msg["hmalert"] = hmalert
end  # callHMAlert!( msg, hmid, isJS, time )


function halfmoon( innerhead, innerbody; modals::AbstractArray{Modal}=Modal[],
    stickyalerts::AbstractArray{SA}=HMStickyAlert[],
    hmcssoverride::AbstractString="", ie11comp::Bool=false,
    darkmode::Bool=true, navbartop::Bool=false, navbarbottom::Bool=false,
    sidebar::Bool=false, dmshort::Bool=true, sbshort::Bool=true,
    classes::Vector{String}=String[], class::AbstractString="",
    kwargs... ) where SA <: HMStickyAlert
    tmphead = createhead( innerhead, hmcssoverride, ie11comp )
    tmpbody = createbody( innerbody, darkmode, navbartop,
        navbarbottom, sidebar, dmshort, sbshort, classes, class; kwargs... )
    addstickyalerts( tmpbody, stickyalerts )
    tmpbody.content = vcat( modals |> vec, tmpbody.content )
    doc( tmphead, tmpbody )
end  # halfmoon( innerhead, innerbody; modals, stickyalerts, hmcssoverride,
     #   ie11comp, darkmode, navbartop, navbarbottom, sidebar, dmshort,
     #   sbshort, classes, class, kwargs... )


function createhead( innerhead, hmcssoverride::AbstractString, ie11comp::Bool )
    tmpoverride = isempty(hmcssoverride) || endswith( hmcssoverride, ".css" ) ?
        hmcssoverride : string( hmcssoverride, ".css" )

    tmphead = deepcopy(innerhead)
    (innerhead isa WebMin.Html.NormalTag && innerhead.tag == "head") ||
        (tmphead = Head(innerhead))

    push!( tmphead.content, Link( href=string( "https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon", ie11comp ? "" : "-variables", ".min.css" ), rel="stylesheet" ) )
    isempty(tmpoverride) ? "" :
        push!( Link( href=tmpoverride, rel="stylesheet" ) )
    tmphead
end  # createhead( innerhead, hmcssoverride, ie11comp )


function createbody( innerbody, darkmode::Bool, navbartop::Bool,
    navbarbottom::Bool, sidebar::Bool, dmshort::Bool, sbshort::Bool,
    classes::Vector{String}, class::AbstractString, kwargs... )
    bodyclass = classes |> deepcopy
    darkmode && push!( bodyclass, "dark-mode" )
    WebMin.Html.combineclasses!( bodyclass, class )

    pageclass = ["page-wrapper"]
    navbartop && push!( pageclass, "with-navbar" )
    navbarbottom && push!( pageclass, "with-navbar-fixed-bottom" )
    sidebar && push!( pageclass, "with-sidebar" )

    tmpbody = deepcopy(innerbody)

    if innerbody isa WebMin.Html.NormalTag && innerbody.tag == "body"
        append!( tmpbody.classes, bodyclass ) |> unique!
    else
        tmpbody = Body( classes=bodyclass, [
            Div( classes=pageclass, innerbody )
            Script(src="https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js")
        ] )
    end  # if innerbody isa NormalTag && innerbody.tag == "body"

    tmpbody.attrs["data-sidebar-shortcut-enabled"] = sbshort
    tmpbody.attrs["data-dm-shortcut-enabled"] = dmshort
    tmpbody
end  # createbody( innerbody, darkmode, navbartop, navbarbottom, sidebar,
     #   dmshort, sbshort, classes, class, kwargs... )


function addstickyalerts( bodytag::Html.NormalTag,
    stickyalerts::AbstractArray{SA} ) where SA <: HMStickyAlert
    isempty(stickyalerts) && return

    ssaflag = isa.( stickyalerts, StaticStickyAlert )
    satag = Div( stickyalerts[ssaflag], class="sticky-alerts" )
    bodytag.content[1].content = vcat( satag, bodytag.content[1].content )
    # all(ssaflag) && return

    route( "/hmstickyalerts.js", stream=true ) do hs::HTTPStream
        openstream(hs)
        
        write( hs, stickyalertprocessing )

        if !all(ssaflag)
            write( hs, "\nhmalerts = {\n" )
            isfirst = true

            for jssa in stickyalerts[.!ssaflag]
                isfirst ? (isfirst = false) : write( hs, ",\n" )
                write( hs, jssa |> doc )
            end  # for jssa in stickyalerts[.!ssaflag]
        end  # if !all(ssaflag)
        
        closestream(hs)
    end  # route( "/hmstickyalerts.js", stream=true ) do hs
    
    push!( bodytag.content, Script( src="/hmstickyalerts.js" ) )
end  # addstickyalerts( bodytag, stickyalerts )


stickyalertprocessing = """function parse_response( payload ) {
  hmalert = null

  for (tag in payload) {
    if (tag == "hmalert") {
      hmalert = payload[tag];
      continue;
    }

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

  if (hmalert !== null) {
    if (hmalert["time"] === undefined)
      hmalerts[hmalert["hmid"]]();
    else
      halfmoon.toastAlert( hmalert["hmid"], parseInt(hmalert["time"]) );
  }
}
"""