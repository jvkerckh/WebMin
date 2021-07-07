export route, getheader, payload, postpayload


"""
```
route( f::Function,
    path::AbstractString;
    method::AbstractString="GET",
    stream::Bool=false,
    scheme::AbstractString="",
    host::AbstractString="" )
```
This function defines a HTTP route for `path` with method `method`, executing the function `f` whenever the path is called from the browser. The flag `stream` indicates whether the route processes HTTP requests in a regular fashion or treats them as HTTP streams.
    
The function `f` must take a single argument of type `Request` if `stream` is `false`, or a single argument of type `HTTPStream` otherwise.

Alternative function:
```
route( path::AbstractString,
    f::Function;
    method="GET",
    stream::Bool=false, 
    scheme::AbstractString="",
    host::AbstractString="" )
```
"""
function route( f::Function, path::AbstractString; method::AbstractString="GET",
    stream::Bool=false, scheme::AbstractString="", host::AbstractString="" )
    escexpr = HTTP.Handlers.generate_gethandler( config[:router], method, scheme, host, path, processfunction( f, stream ) )
    eval( escexpr.args[1] )
end  # route( f, path; method, stream, scheme, host )
# ! HTTP.@register( config[:router], method, path, f ) doesn't work!

route( path::AbstractString, f::Function; method="GET", stream::Bool=false, 
    scheme::AbstractString="", host::AbstractString="" ) =
    route( f, path, method=method, stream=stream, scheme=scheme, host=host )


"""
```
getheader( req::Request,
    field::AbstractString,
    default::AbstractString="" )
    
getheader( hs::HTTPStream,
    field::AbstractString,
    default::AbstractString="" )
    
getheader( ws::WebSocket,
    field::AbstractString,
    default::AbstractString="" )
    
getheader( wsr::WSRoute,
    field::AbstractString,
    default::AbstractString="" )
```
This function gets the header `field` from the given HTTP operation. If there is no such header, the function returns `default`.
"""
getheader( req::Request, field::AbstractString, default::AbstractString="" ) =
    HTTP.header( req, field, default )
getheader( hs::HTTPStream, field::AbstractString,
    default::AbstractString="" ) = getheader( hs.message, field, default )
getheader( ws::WebSocket, field::AbstractString,
    default::AbstractString="" ) = getheader( ws.request, field, default )
getheader( wsr::WSRoute, field::AbstractString,
    default::AbstractString="" ) = getheader( wsr.ws, field, default )


"""
```
payload( req::Request )

payload( hs::HTTPStream )

payload( ws::WebSocket )

payload( ch::WSRoute )
```
This function retrieves the payload from the given HTTP operation and returns it as a `Dict{Symbol,Any}`. In the first two cases this consists of the parameters passed through the URI, in the latter two cases it returns the message as a `Dict` if the message is a valid JSON string, or a normal `String` otherwise.

```
payload( req::Request, field::AbstractString, default=nothing )

payload( hs::HTTPStream, field::AbstractString, default=nothing )

payload( ws::WebSocket, field::AbstractString, default=nothing )

payload( wsr::WSRoute, field::AbstractString, default=nothing )
```
This function gets the value of `field` from the payload of the given HTTP operation. If the payload has no such field, the function returns `default`.
"""
function payload( req::Request )
    contains( HTTP.uri(req), '?' ) || return Dict{Symbol,Any}()

    pars = split.( split( split( HTTP.uri(req), '?' )[2], '&' ), '=' )
    Dict{Symbol,Any}( Symbol(pval[1]) => pval[2] |> parsevalue for pval in pars )
end  # payload( req )

payload( hs::HTTPStream ) = payload(hs.message)

function payload( ws::WebSocket )
    ws.rxpayload |> deepcopy |> String |> parsevalue
end  # payload( ws )

payload( wsr::WSRoute ) = wsr.payload
payload( req::Request, field::AbstractString, default=nothing ) =
    get( payload(req), Symbol(field), default )
payload( hs::HTTPStream, field::AbstractString, default=nothing ) =
    payload( hs.message, field, default )
payload( ws::WebSocket, field::AbstractString, default=nothing ) =
    get( payload(ws), Symbol(field), default )
payload( wsr::WSRoute, field::AbstractString, default=nothing ) =
    get( payload(wsr), Symbol(field), default )
    
"""
```
postpayload( req::Request )

postpayload( hs::HTTPStream )
```
This function retrieves the POST payload from the given HTTP POST request and returns it as a `Dict{Symbol,Any}`. If the request is not a POST request, the function returns an empty dictionary.

```
postpayload( req::Request,
    field::AbstractString,
    default=nothing )

postpayload( hs::HTTPStream,
    field::AbstractString,
    default=nothing )
```
This function gets the value of `field` from the POST payload of the given HTTP request. If the POST payload has no such field, the function returns `default`.
"""
function postpayload( req::Request )
    HTTP.method(req) == "POST" || return Dict{Symbol,Any}()

    webdelimeter = split( getheader( req, "Content-Type" ), '=' )[2]
    inputdata = split( HTTP.body(req) |> String, webdelimeter )[2:(end-1)]
    Dict{Symbol,Any}( processinput(indata) for indata in inputdata )
end  # postpayload( req )

postpayload( hs::HTTPStream ) = postpayload(hs.message)
postpayload( req::Request, field::AbstractString, default=nothing ) =
    get( postpayload(req), Symbol(field), default )
postpayload( hs::HTTPStream, field::AbstractString, default=nothing ) =
    get( postpayload(hs), Symbol(field), default )


Base.getindex( req::Request, field::AbstractString ) = postpayload( req, field )


function processinput( indata::AbstractString )
    intmp = split( indata, "\r\n" )[[2,end-1]]
    par = split( split( intmp[1], "; " )[2], '=' )[2][2:(end-1)]
    Symbol(par) => intmp[2] |> parsevalue
end  # processinput( indata )


function parsevalue( val::AbstractString )
    try
        parsedval = JSON.parse(val)
        parsedval isa Dict || return parsedval
        return parsevalue(parsedval)
    catch
        return val
    end
end  # parsevalue( val )

parsevalue( val::Dict ) =
    Dict{Symbol,Any}( Symbol(key) => val[key] |> parsevalue for key in keys(val) )
parsevalue(val) = val


function errorpage( exc::Exception )
    html( [
        head(link( rel="stylesheet", href="https://www.w3schools.com/w3css/4/w3.css" ))
        body( class="w3-pale-red", Html.div( [
            h1("Error 500 - Something broke!")
            p( class="w3-padding-large", "We're not sure just what happened, but it didn't go the way it's supposed to go." )
        ] ) )
    ] )
end  # errorpage( exc )


function processfunction( f::Function, stream::Bool )
    stream && return HTTP.StreamHandlerFunction(f)

    function (req::Request)
        try
            return f(req)
        catch exc
            @warn( string( "An error has occurred in HTTP Request route \"", req.target, "\". See the stacktrace below for additional information." ) )

            for (ex2, bt) in Base.catch_stack()
                showerror( stderr, ex2, bt )
                println(stderr)
                # Better logging?
            end  # for (ex2, bt) in Base.catch_stack()

            return Response( 500, body=errorpage(exc) )
        end  # try
    end  # excenf
end  # processfunction( f, stream )
