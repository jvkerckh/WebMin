export  container,
        content, contenttitle,
        card, cardtitle,
        row, hmcol, hmcols


function container( inner=""; tag::AbstractString="div", size::Symbol=:fluid, class::AbstractString="", kwargs... )
    size ∈ [:fluid, :sm, :md, :lg, :xl] || (size = :fluid)
    processhmblock( inner, string( "container-", size ), tag, class; kwargs... )
end  # container( inner; tag, size, class, kwargs )


content( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "content", tag, class; kwargs... )

contenttitle( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "content-title", tag, class; kwargs... )

card( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "card", tag, class; kwargs... )

cardtitle( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "card-title", tag, class; kwargs... )

row( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "row", tag, class; kwargs... )


function hmcol( inner=""; tag::AbstractString="div", size::Symbol=:none,
    auto::Bool=false, ncols::Integer=0, class::AbstractString="", kwargs... )
    auto || return hmcols( inner, tag=tag, size=[size], ncols=[ncols], class=class; kwargs... )
    hmclass = string( "col", size === :none ? "" : "-$size", "-auto" )
    processhmblock( inner, hmclass, tag, class; kwargs... )
end  # hmcol( inner; tag, size, auto, ncols, class, kwargs... )


function hmcols( inner=""; tag::AbstractString="div",
    size::Vector{Symbol}=[:none], ncols::Vector{T}=[0],
    class::AbstractString="", kwargs... ) where T <: Integer
    if length(size) != length(ncols)
        @warn "Size vector and columns vector must have equal lengths."
        return ""
    end  # if length(size) != length(ncols)

    isempty(size) && return ""
    hmclass = map( eachindex(size) ) do ii
        string( "col", size[ii] ∈ [:sm, :md, :lg, :xl] ? "-$(size[ii])" : "",
            1 <= ncols[ii] <= 11 ? "-$(ncols[ii])" : "" )
    end
    processhmblock( inner, join( hmclass, " " ), tag, class; kwargs... )
end  # hmcols( inner; tag, size, ncols, class, kwargs... )


function processhmblock( inner, baseclass::AbstractString, tag::AbstractString,
    class::AbstractString; kwargs... )
    tmptag = processtag(tag)
    # Fallback for void tags
    Symbol(tmptag) ∈ WebMin.Html.VOID_TAGS &&
        return processhmblock( baseclass, tag, class; kwargs... )
    
    tmpclass = combineclasses( baseclass, class )
    Core.eval( @__MODULE__, """$tmptag( $(processinner(inner)), class=$tmpclass; $(kwargs |> collect)... )""" |> Meta.parse )
end  # processhmblock( inner, baseclass, tag, class; kwargs... )

function processhmblock( baseclass::AbstractString, tag::AbstractString,
    class::AbstractString; kwargs... )
    tmptag = processtag(tag)
    tmpclass = combineclasses( baseclass, class )
    Core.eval( @__MODULE__, """$tmptag( class=$tmpclass; $(kwargs |> collect)... )""" |> Meta.parse )
end  # processhmblock( baseclass, tag, class; kwargs... )


function processtag( tag::AbstractString )
    tmptag = lowercase(tag)
    tmptag == "div" ? "Html.div" : tmptag
end  # processtag( tag )


function combineclasses( mclass::AbstractString, class::AbstractString )
    isempty(mclass) && isempty(class) && return nothing
    isempty(class) && return "\"$mclass\""
    string( "\"", mclass, " ", class, "\"" )
end  #combineclasses( mclass, class )


processinner( inner ) =
    inner isa AbstractString ? "\"\"\"$inner\"\"\"" : inner
