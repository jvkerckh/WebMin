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
    tmptag ∈ ["div", "map", "mark", "time", "summary"] ? "Html.$tmptag" : tmptag
end  # processtag( tag )


function combineclasses( mclass::AbstractString, class::AbstractString )
    isempty(mclass) && isempty(class) && return nothing
    isempty(class) && return "\"$mclass\""
    string( "\"", mclass, " ", class, "\"" )
end  # combineclasses( mclass, class )


processinner( inner ) =
    inner isa AbstractString ? "\"\"\"$inner\"\"\"" : inner


function makeBasicComponent( hmclass::AbstractString, tag::AbstractString;
    fixedtag::Bool=false, noinner::Bool=false, kwargs... )
    compname = uppercasefirst.(split( hmclass, "-" )) |> join
    tmpinner = noinner ? "" : "inner=\"\""
    tmpinner2 = noinner ? "" : " inner,"
    tagarg = fixedtag ? "" : """ tag::AbstractString="$tag","""
    tmptag = fixedtag ? "\"$tag\"" : "tag"

    Core.eval( @__MODULE__, """$compname( $tmpinner;$tagarg id="",
        classes::Vector{S}=String[], class::AbstractString="",
        styles::Dict{String, A1}=Dict{String, Any}(),
        attrs::Dict{String, A2}=Dict{String, Any}(),
        kwargs... ) where {S <: AbstractString, A1, A2} =
        Tag( $tmptag,$(tmpinner2) id=id, classes=vcat( "$hmclass", classes ),
            class=class, styles=styles, attrs=attrs; $(kwargs |> collect)...,
            kwargs... )""" |>
        Meta.parse )
end  # makeBasicComponent( hmclass, tag; fixedtag )
