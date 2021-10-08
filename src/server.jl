export  serverup, serverdown, clearroutes


config = Dict{Symbol,Any}(
    :server_address => ip"127.0.0.1",
    :server_port => 8000,
    :use_websockets => false,
    :websocket_port => 0,
    :server_listener => nothing,
    :router => HTTP.Router(),
    :server => nothing,
    :websocket_listener => nothing,
    :websocket => nothing,
    :wsroute_list => Dict{String,Function}()
)
workingmemory = Dict{Int,Dict{Symbol,Any}}()


function clearroutes()
    if !isnothing(config[:server])
        @warn( "Can't clear routes from a running server." )
        return
    end  # if !isnothing(config[:server])

    config[:router] = HTTP.Router()
    empty!( config[:wsroute_list] )
end  # clearroutes()


"""
```
serverup( address::Union{IPAddr, AbstractString}="localhost";
    port::Int=8000,
    ws_port::Int=0 )
```
This function starts a server listening at `address` and `port`. If `ws_port` is non zero and different from `port`, it also opens a dedicated websocket port at `ws_port`. If a server is already running, this function will shut it down first.
"""
function serverup( address::Union{IPAddr, AbstractString}="localhost";
    port::Int=8000, ws_port::Int=0 )
    serverdown()
    configserver( address, port=port, ws_port=ws_port )

    if config[:use_websockets]
        config[:websocket_listener] = Sockets.listen(
            config[:server_address], config[:websocket_port] )
        config[:websocket] = @async HTTP.serve( ; server=config[:websocket_listener], stream=true ) do hs::HTTP.Stream
            upgradeStream( hs, routeChannel )
            # Some stuff that needs to happen.
        end  # HTTP.serve( ... ) do hs

        @info string( "Dedicated websocket listener opened at ",
        config[:server_address], ":", config[:websocket_port] )
    end  # if config[:use_websocket]

    config[:server_listener] = Sockets.listen(
        config[:server_address], config[:server_port] )
    config[:server] = @async HTTP.serve( config[:router],
        server=config[:server_listener] )
    
    @info string( "Server listener opened at ",
    config[:server_address], ":", config[:server_port] )
end  # serverup( address; port, ws_port )


"""
```
serverdown()
```
This function shuts down the server if its running.
"""
function serverdown()
    isnothing(config[:server_listener]) ||
        close(config[:server_listener])
    isnothing(config[:websocket_listener]) ||
        close(config[:websocket_listener])
    
    config[:server] = nothing
    config[:server_listener] = nothing
    config[:websocket_listener] = nothing
    empty!(workingmemory)
end  # serverdown()


function configserver( address::IPAddr; port::Int=8000,
    ws_port::Int=0 )
    config[:server_address] = address
    config[:server_port] = port
    config[:use_websockets] = ws_port > 0 && ws_port != port
    config[:websocket_port] = config[:use_websockets] ? ws_port : 0
end  # configserver( address; port, ws_port )

function configserver( address::AbstractString; port::Int=8000,
    ws_port::Int=0 )
    addressparsed = lowercase(address) == "localhost" ? ip"127.0.0.1" :
        tryparse( IPAddr, address )
    isnothing(addressparsed) ||
        return configserver( addressparsed, port=port, ws_port=ws_port )
    @warn string( "'", address, "' is not a valid IP (v4 or v6) address" )
end  # configserver( address; port, ws_port )
