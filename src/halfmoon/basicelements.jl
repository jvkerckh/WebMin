fns = [
    "Btn",
    "HMCode",
    "HMImg",
    "Hyperlink",
    "HMTable", "TableResponsive"
]

Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


function Btn( inner=""; id="", type::Symbol=:default, size::Symbol=:default,
    altdm::Bool=false, rounded::Bool=false, square::Bool=false,
    issubmit::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    btnclass = ["btn"]
    size ∈ [:lg, :sm, :block] && push!( btnclass, "btn-$size" )
    type ∈ [:primary, :danger, :link, :success, :secondary] && push!( btnclass, "btn-$type" )
    altdm && push!( btnclass, "alt-dm" )
    rounded && push!( btnclass, "btn-rounded" )
    square && push!( btnclass, "btn-square" )
    Tag( "button", inner, id=id, classes=vcat( btnclass, classes ), class=class,
        styles=styles, attrs=attrs, type=issubmit ? "submit" : "button";
        kwargs... )
end  # Btn( inner; id, type, size, altdm, rounded, square, issubmit, classes,
     #   class, styles, attrs, kwargs... )


HMCode( inner=""; id="", classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Tag( "code", inner, id=id, classes=vcat( "code", classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )


function HMImg( src::AbstractString, alt::AbstractString="";
    id="", fluid::Bool=true, rounding::Symbol=:none,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    imgclass = String[]
    fluid && push!( imgclass, "img-fluid" )
    rounding ∈ [:rounded, :circle, :top, :bottom, :left, :right] &&
        push!( imgclass, string( "rounded", rounding === :rounded ? "" : string( "-$rounding" ) ) )
    Tag( "img", id=id, classes=vcat( imgclass, classes ), class=class,
        styles=styles, attrs=attrs, src=isempty(src) ? nothing : src,
        alt=isempty(alt) ? nothing : alt; kwargs... )
end  # HMImg( src, alt, tag, id, fluid, rounding, classes, class, styles,
     #   attrs, kwargs... )


Hyperlink( href=AbstractString, inner=""; tag::AbstractString="a", id="",
    underline::Bool=false, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Tag( tag, inner, id=id,
        classes=vcat( string( "hyperlink", underline ? "-underline" : "" ),
        classes ), class=class, styles=styles, attrs=attrs,
        href=isempty(href) ? nothing : href; kwargs... )


function HMTable( tablehead, tablebody; id="", outerpadding::Bool=true,
    striped::Bool=false, hover::Bool=false, border::Symbol=:none,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    tbclass = ["table"]
    outerpadding || push!( tbclass, "table-no-outer-padding" )
    striped && push!( tbclass, "table-striped" )
    hover && push!( tbclass, "table-hover" )
    border ∈ [:inner, :outer, :both] && push!( tbclass, string( "table", border === :both ? "" : "-$border", "-bordered" ) )

    (tablehead isa WebMin.Html.NormalTag && tablehead.tag == "thead") ||
        (tablehead = Thead(tablehead))
    (tablebody isa WebMin.Html.NormalTag && tablebody.tag == "tbody") ||
        (tablebody = Tbody(tablebody))

    Tag( "table", [tablehead, tablebody], id=id,
        classes=vcat( tbclass, classes ), class=class, styles=styles,
        attrs=attrs; kwargs... )
end  # HMTable( tablehead, tablebody; id, outerpadding, striped, hover, border,
     #   classes, class, styles, attrs, kwargs... )

makeBasicComponent( "table-responsive", "div" )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
