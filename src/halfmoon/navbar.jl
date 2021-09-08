export  navbar,
        navbarcontent,
        navbarbrand,
        navbartext,
        navbarnav,
        navitem,
        navlink


navbar( inner=""; class::AbstractString="", kwargs... ) =
    processhmblock( inner, "navbar", "nav", class; kwargs... )

navbarcontent( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "navbar-content", tag, class; kwargs... )

navbarbrand( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "navbar-brand", tag, class; kwargs... )

navbartext( inner=""; tag::AbstractString="span", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "navbar-text", tag, class; kwargs... )

navbarnav( inner=""; tag::AbstractString="ul", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "navbar-nav", tag, class; kwargs... )


function navitem( inner=""; tag::AbstractString="li", class::AbstractString="",
    active::Bool=false, kwargs... )
    processhmblock( inner, string( "nav-item", active ? " active" : "" ), tag, class; kwargs... )
end  # navitem( inner; tag, class, active, kwargs... )


navlink( inner=""; tag::AbstractString="a", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "nav-link", tag, class; kwargs... )
