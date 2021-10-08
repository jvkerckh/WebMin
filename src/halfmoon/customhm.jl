export initCustomHM, setCustomHM!, generateCustomHMCSS

const lightdarkdict = Dict(
    :both => "",
    :light => "lm-",
    :dark => "dm-" )
const statedict = Dict(
    :none => "",
    :focus => "-focus",
    :hover => "-hover",
    :active => "-active",
    :activehover => "-active-hover" )


initCustomHM() = Dict{String,Dict{String,String}}()


function setCustomHM!( chm::Dict{String,Dict{String,String}},
    component::AbstractString, variable::AbstractString,
    value::AbstractString=""; scope::AbstractString="",
    lightdark::Symbol=:both, state::Symbol=:none )
    haskey( lightdarkdict, lightdark ) || error("Parameter lightdark takes only values in :both, :light, :dark")
    haskey( statedict, state ) || error("Parameter state takes only values in :none, :focus, :hover, :active, :activehover")
    isempty(value) || haskey( chm, scope ) ||
        (chm[scope] = Dict{String,String}())

    varname = string( lightdarkdict[lightdark], component, "-", variable,
        statedict[state] )
    
    if !isempty(value)
        haskey( chm, scope ) || (chm[scope] = Dict{String,String}())
        chm[scope][varname] = value
        return
    end  # if !isempty(value)

    haskey( chm, scope ) || return
    delete!( chm[scope], varname )
    isempty( chm[scope] ) && delete!( chm, scope )
end  # setCustomHM!( chm, component, variable, value; scope, lightdark, state )


function generateCustomHMCSS( chm::Dict{String,Dict{String,String}},
    fname::AbstractString="customhm" )
    fname = endswith( fname, ".css" ) ? fname : string( fname, ".css" )

    route(fname) do http::Request
        Respond( 200, ["Content-Type" => "text/css"],
            body=convertCustomHM(chm) )
    end  # route(fname) do http
end  # generateCustomHMCSS( chm, fname )


function convertCustomHM(chm::Dict{String,Dict{String,String}})
    scopestr = String[]

    if haskey( chm, "" )
        vars = map(chm[""] |> keys |> collect) do var
            string( "    --", var, ": ", chm[""][var], ";" )
        end  # map(...) do var

        scopestr = string( ":root {\n", join( vars, "\n" ), "\n}" )
    end

    scopes = filter( scope -> !isempty(scope), chm |> keys |> collect )

    scopestr = vcat( scopestr, map(scopes) do scope
        vars = map(chm[scope] |> keys |> collect) do var
            string( "    --", var, ": ", chm[scope][var], ";" )
        end  # map(...) do var

        string( ".", scope, " {\n", join( vars, "\n" ), "\n}" )
    end )  # for scope in scopes

    join( scopestr, "\n\n" )
end  # convertCustomHM(chm)
