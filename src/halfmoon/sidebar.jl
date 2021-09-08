export  sidebar,
        sidebarmenu,
        sidebarbrand,
        sidebartitle,
        sidebarlink,
        sidebardivider,
        sidebarcontent,
        sidebaricon


sidebar( inner=""; class::AbstractString="", kwargs... ) =
    processhmblock( inner, "sidebar", "div", class; kwargs... )

sidebarmenu( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "sidebar-menu", tag, class; kwargs... )
    
sidebarbrand( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "sidebar-brand", tag, class; kwargs... )

sidebartitle( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "sidebar-title", tag, class; kwargs... )


function sidebarlink( inner=""; tag::AbstractString="div",
    class::AbstractString="", active::Bool=false, withicon::Bool=false,
    kwargs... )
    processhmblock( inner, string( "sidebar-link", withicon ? " sidebar-link-with-icon" : "", active ? " active" : "" ), tag, class; kwargs... )
end  # sidebarlink( inner; tag, class, active, withicon, kwargs... )


sidebardivider( ; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( "", "sidebar-divider", tag, class; kwargs... )

sidebarcontent( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "sidebar-content", tag, class; kwargs... )

sidebaricon( inner=""; tag::AbstractString="span", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "sidebar-icon", tag, class; kwargs... )
