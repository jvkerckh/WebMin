export  btn,
        hmcode,
        hmimg,
        hyperlink,
        hmtable, tableresponsive


function btn( inner=""; type::Symbol=:default, size::Symbol=:default,
    altdm::Bool=false, rounded::Bool=false, square::Bool=false,
    issubmit::Bool=false, class::AbstractString="", kwargs... )
    btnclass = ["btn"]
    size ∈ [:lg, :sm, :block] && push!( btnclass, "btn-$size" )
    type ∈ [:primary, :danger, :link, :success, :secondary] && push!( btnclass, "btn-$type" )
    altdm && push!( btnclass, "alt-dm" )
    rounded && push!( btnclass, "btn-rounded" )
    square && push!( btnclass, "btn-square" )
    processhmblock( inner, join( btnclass, " " ), "button", class, type=issubmit ? "submit" : "button"; kwargs... )
end  # btn( inner; type, size, altdm, rounded, square, issubmit, class,
     #   kwargs... )


hmcode( inner=""; class::AbstractString="", kwargs... ) =
    processhmblock( inner, "code", "code", class; kwargs... )


function hmimg( src::AbstractString, alt::AbstractString=""; fluid::Bool=true,
    rounding::Symbol=:none, class::AbstractString="", kwargs... )
    imgclass = String[]
    fluid && push!( imgclass, "img-fluid" )
    rounding ∈ [:rounded, :circle, :top, :bottom, :left, :right] && push!( imgclass, string( "rounded", rounding === :rounded ? "" : string( "-$rounding" ) ) )
    processhmblock( join( imgclass, " " ), "img", class, src=src, alt=isempty(alt) ? nothing : alt; kwargs... )
end  # hmimg( src, alt; fluid, rounding, class, kwargs... )


hyperlink( href::AbstractString, inner=""; tag::AbstractString="a",
    underline::Bool=false, class::AbstractString="", kwargs... ) =
    processhmblock( inner, string( "hyperlink", underline ? "-underline" : "" ), tag, class, href=isempty(href) ? nothing : href; kwargs... )


function hmtable( tablehead, tablebody; outerpadding::Bool=true,
    striped::Bool=false, hover::Bool=false, border::Symbol=:none,
    class::AbstractString="", kwargs... )
    tbclass = ["table"]
    outerpadding || push!( tbclass, "table-no-outer-padding" )
    striped && push!( tbclass, "table-striped" )
    hover && push!( tbclass, "table-hover" )
    border ∈ [:inner, :outer, :both] && push!( tbclass, string( "table", border === :both ? "" : "-$border", "-bordered" ) )
    processhmblock( [thead(tablehead), tbody(tablebody)], join( tbclass, " " ), "table", class; kwargs... )
end  # hmtable( tablehead, tablebody; outerpadding, striped, hover, border,
     #   class, kwargs... )


tableresponsive( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "table-responsive", tag, class; kwargs... )