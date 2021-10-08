fns = [
    "Navbar",
    "NavbarContent",
    "NavbarBrand",
    "NavbarText",
    "NavbarNav",
    "NavItem",
    "NavLink"
]

Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


makeBasicComponent( "navbar", "nav", fixedtag=true )
makeBasicComponent( "navbar-content", "div" )
makeBasicComponent( "navbar-brand", "div" )
makeBasicComponent( "navbar-text", "span" )
makeBasicComponent( "navbar-nav", "ul" )

function NavItem( inner=""; tag::AbstractString="li", id="", active::Bool=false,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    niclass = ["nav-item"]
    active && push!( niclass, "active" )
    Tag( tag, inner, id=id, classes=vcat( niclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # NavItem( inner; tag, id, active, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "nav-link", "a" )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
