fns = [
    "Sidebar",
    "SidebarMenu",
    "SidebarBrand",
    "SidebarTitle",
    "SidebarLink",
    "SidebarDivider",
    "SidebarContent",
    "SidebarIcon"
]

Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


makeBasicComponent( "sidebar", "div" )
makeBasicComponent( "sidebar-menu", "div" )
makeBasicComponent( "sidebar-brand", "div" )
makeBasicComponent( "sidebar-title", "div" )

function SidebarLink( inner=""; tag::AbstractString="div", id="",
    active::Bool=false, withicon::Bool=false, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    sblclass = ["sidebar-link"]
    withicon && push!( sblclass, "sidebar-link-with-icon" )
    active && push!( sblclass, "active" )
    Tag( tag, inner, id=id, classes=vcat( sblclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # SidebarLink( inner; tag, id, active, withicon, classes, class, styles,
     #   attrs, kwargs... )

makeBasicComponent( "sidebar-divider", "div", noinner=true )
makeBasicComponent( "sidebar-content", "div" )
makeBasicComponent( "sidebar-icon", "span" )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
