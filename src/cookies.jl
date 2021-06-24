export getCookie, setCookie!


"""
```
getCookie(
    re::Union{Request, Response, HTTPStream},
    field::AbstractString,
    default=nothing )
```
This function gets the cookie with name 'field' from the HTTP operation `re`. If no such cookie exists, the function returns `default`.

Alternate versions:
```
getCookie( ws::WebSocket,
    field::AbstractString,
    default=nothing )

getCookie( wsr::WSRoute,
    field::AbstractString,
    default=nothing )
```
"""
function getCookie( re::Union{Request, Response, HTTPStream},
    field::AbstractString, default=nothing )
    HTTP.hasheader( re, "Cookie" ) || return default

    field = strip(field)
    cookies = HTTP.header( re, "Cookie" )
    cookies = split.( split( cookies, "; " ), "=" )
    cind = findfirst( cookie -> cookie[1] == field, cookies )

    isnothing(cind) ? default : cookies[cind][2] |> JSON.parse
end  # getCookie( re::Union{Request, Response}, field, default )

getCookie( ws::WebSocket, field::AbstractString, default=nothing ) =
    getCookie( ws.request, field, default )
getCookie( wsr::WSRoute, field::AbstractString, default=nothing ) =
    getCookie( wsr.ws, field, default )


"""
```
setCookie!( res::Response,
    fvals::Pair... )
```
This function sets the cookies `fvals`, given as field/value pairs, in the HTTP Response `res`.

Alternate versions:
```
setCookie!( res::Response,
    field::AbstractString,
    value )
```
This function sets a cookie `field` to `value` in the HTTP Response `res`.
"""
function setCookie!( res::Response, fvals::Pair... )
    isempty( fvals ) && return

    cookies = map( fval -> [strip(fval[1]), string(fval[2])], fvals )

    (getindex.( cookies, 1 ) |> allunique) ||
        throw("[Ambiguous call] Cookies have non-unique fields, can't set.")

    if !HTTP.hasheader( res, "Set-Cookie" )
        HTTP.setheader( res, "Set-Cookie" => join( join.( cookies, "=" ), "; " ) )
        return
    end  # if !HTTP.hasheader( res, "Set-Cookie" )

    oldcookies = HTTP.header( res, "Set-Cookie" )
    oldcookies = split.( split( oldcookies, "; " ), "=" )

    for ii in eachindex(cookies)
        cind = findfirst( cookie -> cookie[1] == cookies[ii][1], oldcookies )
        isnothing(cind) ? push!( oldcookies, cookies[ii] ) : (oldcookies[cind][2] = string(cookies[ii][2]))
    end  # for ii in eachindex(cookies)

    HTTP.setheader( res, "Set-Cookie" => join( join.( oldcookies, "=" ), "; " ) )
end  # setCookie!( res, fvals )

setCookie!( res::Response, field::AbstractString, value ) =
    setCookie!( res, field => value )
