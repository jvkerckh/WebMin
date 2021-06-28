export  respond,
        getSid,
        initMessage!,
        changeInnerHTML!,
        removeElement!,
        changeElementAttribute!


"""
```
respond( res::AbstractString )
```
This function wraps the text in `res` in a HTTP response with status code 200.
"""
respond( res::AbstractString ) = Response( 200, body=res )


"""
```
getSid(
    req::Request;
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
initMessage!()
```
This function initialises a response dictionary to be sent as a message over a websocket.
"""
initMessage!() = Dict{String,Dict{String,Any}}()


"""
```
changeInnerHTML!(
    msg::Dict{String,Dict{String,Any}},
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
removeElement!(
    msg::Dict{String,Dict{String,Any}},
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
changeElementAttribute!(
    msg::Dict{String,Dict{String,Any}},
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
