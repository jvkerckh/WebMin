export WSRoute, sendMessage


"""
WSRoute is an internal object defining a websocket route over the dedicated websocket port. Although this struct is exported, it should only be used for argument definition when defining websocket routes.
"""
struct WSRoute
    ws::WebSocket
    payload::Dict{Symbol,Any}

    function WSRoute( ws::WebSocket )
        wspayload = payload( ws, "payload" )
        new( ws, isnothing(wspayload) ? Dict{Symbol,Any}() : wspayload )
    end  # WSRoute( ws )
end  # struct WSRoute


"""
```
sendMessage( wsr::WSRoute,
    msg::Union{AbstractString, Dict} )
```
This function sends `mgs` over the dedicated websocket attached to `wsr`.
"""
sendMessage( wsr::WSRoute, msg::Union{AbstractString, Dict} ) =
    sendMessage( wsr.ws, msg )
    

function routeChannel( ws::WebSocket )
    wsrname = payload( ws, "wsroute" )

    if !haskey( config[:wsroute_list], wsrname )
        @warn string( "Web socket route \"", wsrname, "\" not defined" )
        sendMessage( ws, string( "Web socket route \"", wsrname, "\" not defined" ) )
        return
    end  # if !haskey( config[:wsroute_list], wsrname )

    @eval $ws |> WSRoute |> config[:wsroute_list][$wsrname]
end  # routeChannel( ws )


Base.getindex( wsr::WSRoute, field::AbstractString ) = payload( wsr, field )
