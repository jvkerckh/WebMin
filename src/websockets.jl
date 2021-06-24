export wsroute, injectWebsocket, sendMessage


"""
```
wsroute( f::Function,
    path::AbstractString;
    scheme::AbstractString="",
    host::AbstractString="",
    dedicated::Bool=false )
```
This function creates a websocket route on `path`, executing the function `f` when it is called. The flag `dedicated` indicates whether the websocket is run over the normal server port, or if it uses the dedicated websocket port.

The function `f` must take a single argument of type `WebSocket` if `dedicated` is `false`, or a single argument of type `WSRoute` otherwise.

Alternative function:
```
wsroute( path::AbstractString,
    f::Function;
    scheme::AbstractString="",
    host::AbstractString="",
    dedicated::Bool=false )
```
"""
function wsroute( f::Function, path::AbstractString; scheme::AbstractString="",
    host::AbstractString="", dedicated::Bool=false )
    if dedicated
        config[:wsroute_list][path] = f
        return
    end  # if dedicated

    fext( hs::HTTPStream ) = upgradeStream( hs, f )
    route( fext, path, stream=true, scheme=scheme, host=host )
end  # wsroute( f, path, scheme, host )

wsroute( path::AbstractString, f::Function; scheme::AbstractString="",
    host::AbstractString="", dedicated::Bool=false ) = wsroute( f, path,
    scheme=scheme, host=host, dedicated=dedicated )


"""
```
injectWebsocket( name::AbstractString,
    path::AbstractString )
```
This function injects the JavaScript code that sets up a websocket to `path`, and assigns it to variable `name`.

```
injectWebsocket()
```
This function injects the JavaScript code that sets up a dedicated websocket on the server-defined port.
"""
injectWebsocket( name::AbstractString, path::AbstractString ) =
    websocketJS( name, path )
injectWebsocket() = websocketJS("ws")


"""
```
sendMessage( ws::WebSocket,
    msg::AbstractString )
    
sendMessage( ws::WebSocket,
    msg::Dict )
```
This function sends `msg` over the websocket `ws`. The latter version transforms the dictionary to a JSON string prior to sending the message.
"""
sendMessage( ws::WebSocket, msg::AbstractString ) = write( ws, msg )
sendMessage( ws::WebSocket, msg::Dict ) =
    isempty(msg) || write( ws, msg |> json )


function upgradeStream( hs::HTTPStream, f::Function )
    HTTP.WebSockets.upgrade( hs; binary=false ) do ws::WebSocket
        while !eof(ws)
            try
                if isopen(ws)
                    readavailable(ws)
                    f(ws)
                    empty!(ws.rxpayload)
                    # Necessary to clear the buffer of the websocket, will
                    #   cause errors otherwise.
                end  # if isopen(ws)
            catch exc
                if isopen(ws)
                    if !(exc isa HTTP.WebSockets.WebSocketError) || (exc.status != 0x03e9)
                        rethrow(exc)
                    end  # if !(exc isa WebSocketError) || ...
                    # No need to report errors caused by closing websockets.

                    write( ws, string(exc) )
                end  # if isopen(ws)
            end  # catch exc
        end  # while !eof(ws)

        ws.txclosed = true
        # This line prevents errors being thrown by Julia when the HTTP.WebSockets.close(ws) function is invoked.
    end  # HTTP.WebSockets.upgrade( ... ) do ws
end  # upgradeStream( hs, f )


function websocketJS( name::AbstractString,
    path::Union{AbstractString, Nothing}=nothing )
    wspath = string( "'ws://' + ", isnothing(path) ? "window.location.hostname + ':' + $(config[:websocket_port]) + '/'" : "window.location.host + '$path'" )

    script("""var $name = new WebSocket($wspath);

    $name.onopen = function (event) {
        console.log('Websocket connection to', $name.url, 'opened.');
    }

    $name.onclose = function (event) {
        console.log('Websocket connection to', $name.url, 'closed.');
    }
    
    $name.onmessage = function (event) {
        var payload = event.data;

        if (payload.startsWith('{') && payload.endsWith('}')) {
            parse_response(JSON.parse(payload));
        } else
            console.log(event.data);
        }""")
end  # websocketJS( name, path )
