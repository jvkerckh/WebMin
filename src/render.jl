export injectResponsiveness, servefile, streamfile


const extensions = Dict(
    ".css" => "text/css",
    ".ico" => "image/x-icon",
    ".js" => "text/javascript",
    ".svg" => "image/svg+xml"
)


"""
```
injectResponsiveness()
```
This function injects the JavaScript that permits straightforward updating of (named) parts of the webpage.
"""
function injectResponsiveness()
    pathnames = joinpath.( [Base.source_dir(), Base.source_path() |> dirname, pwd(), pathof(WebMin) |> dirname], "../res/jscripts.js" )
    append!( pathnames, ["res/jscripts.js", "/res/jscripts.js"] )
    pathnames = normpath.(pathnames)
    for pname in pathnames
        println( pname, ispath(pname) ? "" : " not", " okay" )
    end

    route( "/jscript.js", stream=true ) do hs::HTTPStream
        pathname = joinpath( Base.source_dir(), "../res/jscripts.js" )
        ispath(pathname) || (pathname = "res/jscripts.js")  # Local tests.
        streamfile( hs, pathname )
    end  # route( "/jscript.js", stream=true ) do hs
    
    script( src="/jscript.js" )
end  # injectResponsiveness()


"""
```
servefile( fname::AbstractString )
```

```
servefile( fname::AbstractString
    ctype::AbstractString )
```
This function reads the file with name `fname` and serves it as a status 200 HTTP response. If the argument `ctype` is provided, the content type of the file is set to this. The function does not check if the file exists!
"""
servefile( fname::AbstractString ) = Response( 200,
    ["Content-Type" => get( extensions, splitext(fname)[2], "text/plain" )],
    body=read(fname) )

servefile( fname::AbstractString, ctype::AbstractString ) =
    Response( 200, ["Content-Type" => ctype], body=read(fname) )


"""
```
streamfile( hs::HTTPStream,
    fname::AbstractString )
```

```
streamfile( hs::HTTPStream,
    fname::AbstractString,
    ctype::AbstractString )
```
This function reads the file with name `fname` and writes it to the HTTP stream `hs`. If the argument `ctype` is provided, the content type of the file is set to this.
"""
function streamfile( hs::HTTPStream, fname::AbstractString,
    ctype::AbstractString )
    HTTP.setheader( hs, "Content-Type" => ctype )
    startwrite(hs)
  
    open(fname) do io
      while !eof(io)
        write( hs, readavailable(io) )
      end  # while !eof(io)
    end  # open(fname) do io
  
    closewrite(hs)  
end  # streamfile( hs, fname, ctype )

streamfile( hs::HTTPStream, fname::AbstractString ) =
    streamfile( hs, fname, get( extensions, splitext(fname)[2], "text/plain" ) )
