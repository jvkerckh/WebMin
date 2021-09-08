export  respond,
        sendUpdate,
        getSid,
        initSessionMemory!,
        initMessage!,
        changeInnerHTML!,
        removeElement!,
        changeElementAttribute!,
        setElementStyle!,
        removeElementStyle!,
        setElementClass!,
        addElementClass!,
        removeElementClass!


"""
```
respond( res::AbstractString )
```
This function wraps the text in `res` in a HTTP response with status code 200.

```
respond( res::Dict{String,Dict{String,Any}} )
```
This function wraps the page update instructions in `res` in a HTTP response with status code 200.
"""
respond( res::AbstractString ) = Response( 200, body=res )
respond( res::Dict{String,Dict{String,Any}} ) = res |> json |> respond


"""
```
sendUpdate( res::Dict{String,Dict{String,Any}} )
```
This function takes the page update commands in `res`, transforms them into a JSON string, and sends them as a HTTP response with status code 200.
"""
sendUpdate( res::Dict{String,Dict{String,Any}} ) = Response( 200, res |> json )


"""
```
getSid( req::Request;
    generate::Bool=false )
```
This function retrieves the session ID from the HTTP request `sid`, and will generate a new one if necessary if the flag `generate` is set. It also returns the Julia memory associated with the session ID.
    
If the `generate` flag is NOT set, the request MUST provide a `sid` cookie.
"""
function getSid( req::Request; generate::Bool=false )
    sid = getCookie( req, "sid" )
    haskey( workingmemory, sid ) &&
        (workingmemory[sid][:lastaccesstime] = now())
    generate || return (sid, workingmemory[sid])
  
    if isnothing(sid)
        sid = rand(Int)
        sid < 0 && (sid -= typemin(Int))
    end  # if isnothing(sid)

    haskey( workingmemory, sid ) ||
        (workingmemory[sid] = Dict{Symbol,Any}( :lastaccesstime => now() ))
    return sid, workingmemory[sid]
end  # getSid( req; generate )

getSid( hs::HTTPStream; generate::Bool=false ) =
    getSid( hs.message, generate=generate )
getSid( ws::WebSocket; generate::Bool=false ) =
    getSid( ws.request, generate=generate )
getSid( wsr::WSRoute; generate::Bool=false ) =
    getSid( wsr.ws, generate=generate )


"""
```
initSessionMemory!( sessionmemory::Dict{Symbol,Any},
    field::Symbol,
    value )
```
This function initialises `field` of `sessionmemory` to `value` if it doesn't have a value yet, and then returns the current value of this field.
"""
initSessionMemory!( sessionmemory::Dict{Symbol,Any}, field::Symbol, value ) =
    haskey( sessionmemory, field ) ? sessionmemory[field] : (sessionmemory[field] = deepcopy(value))


"""
```
initMessage!()
```
This function initialises a response dictionary to be sent as a message over a websocket.
"""
initMessage!() = Dict{String,Dict{String,Any}}()


"""
```
changeInnerHTML!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    contents;
    append::Bool=false )
```
This function adds an instruction to `msg` to change the contents of the HTML element with `id` to `contents`. If the flag `append` is set, the contents of the element get appended; if not, they are replaced.
"""
function changeInnerHTML!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString, contents; append::Bool=false )
    haskey( msg, id ) || (msg[id] = Dict{String,Any}() )
    msg[id]["type"] = append ? 0 : 1
    msg[id]["data"] = string(contents)
end  # changeInnerHTML!( msg, id, contents; append )


"""
```
removeElement!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString )
```
This function adds an instruction to `msg` to remove the HTML element with `id` from the page.
"""
function removeElement!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString )
    haskey( msg, id ) || (msg[id] = Dict{String,Any}() )
    msg[id]["type"] = -1
    msg[id]["data"] = nothing
end  # removeElement!( msg, id )


"""
```
changeElementAttribute!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    attr::AbstractString,
    val )
```
This function adds an instruction to `msg` to change the value of `attr` of the HTML element with `id` to `val`.
"""
function changeElementAttribute!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString, attr::AbstractString, val )
    haskey( msg, id ) || (msg[id] = Dict{String,Any}() )
    msg[id][attr] = val
end  # changeElementAttribute!( msg, id, attr, val )


"""
```
setElementStyle!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    attr::AbstractString,
    val )
```
This function adds an instruction to `msg` to change the value of style property `attr` of the HTML element with `id` to `val`.
"""
function setElementStyle!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString, attr::AbstractString, val )
    haskey( msg, id ) || (msg[id] = Dict{String,Any}() )
    haskey( msg[id], "style" ) || (msg[id]["style"] = Dict{String,Any}() )
    msg[id]["style"][attr] = val
end  # setElementStyle!( msg, id, attr, val )


"""
```
removeElementStyle!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    attr::AbstractString )
```
This function adds an instruction to `msg` to remove the style property `attr` from the HTML element with `id`.
"""
removeElementStyle!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString, attr::AbstractString ) =
    setElementStyle!( msg, id, attr, "" )


"""
```
setElementClass!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    class::AbstractString,
    active::Bool )
```
This function adds an instruction to `msg` to set the flag of `class` of the HTML element with `id` to `active`.
"""
function setElementClass!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString, class::AbstractString, active::Bool )
    haskey( msg, id ) || (msg[id] = Dict{String,Any}() )
    haskey( msg[id], "class" ) || (msg[id]["class"] = Dict{String,Any}() )
    msg[id]["class"][class] = active
end  # setElementClass!( msg, id, class, active )


"""
```
addElementClass!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    class::AbstractString )
```
This function adds an instruction to `msg` to add the class `class` to the HTML element with `id`.
"""
addElementClass!( msg::Dict{String,Dict{String,Any}}, id::AbstractString,
    class::AbstractString ) = setElementClass!( msg, id, class, true )

"""
```
removeElementClass!( msg::Dict{String,Dict{String,Any}},
    id::AbstractString,
    class::AbstractString )
```
This function adds an instruction to `msg` to remove the class `class` from the HTML element with `id`.
"""
removeElementClass!( msg::Dict{String,Dict{String,Any}}, id::AbstractString,
    class::AbstractString ) = setElementClass!( msg, id, class, false )
