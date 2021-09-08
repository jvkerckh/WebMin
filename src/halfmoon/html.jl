export halfmoon


function halfmoon( innerhead, innerbody; hmcssoverride::AbstractString="", ie11comp::Bool=false, darkmode::Bool=true, navbartop::Bool=false, navbarbottom::Bool=false, sidebar::Bool=false, dmshort::Bool=true, sbshort::Bool=true, class::AbstractString="", kwargs... )
    tmpoverride = isempty(hmcssoverride) || endswith( hmcssoverride, ".css" ) ?
        hmcssoverride : string( hmcssoverride, ".css" )

    bodyclass = String[]
    darkmode && push!( bodyclass, "dark-mode" )
    isempty(class) || push!( bodyclass, class )

    pageclass = ["page-wrapper"]
    navbartop && push!( pageclass, "with-navbar" )
    navbarbottom && push!( pageclass, "with-navbar-fixed-bottom" )
    sidebar && push!( pageclass, "with-sidebar" )
    
    # Add functionality to override standard Halfmoon template.

    html([
        head(vcat(
            innerhead isa AbstractArray ? innerhead : string(innerhead),
            link( href=string( "https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon", ie11comp ? "" : "-variables", ".min.css" ), rel="stylesheet" ),
            isempty(tmpoverride) ? "" :
                link( href=tmpoverride, rel="stylesheet" )
        ))

        body( class=join( bodyclass, " " ), data__sidebar__shortcut__enabled=sbshort, data__dm__shortcut__enabled=dmshort,
            Html.div( class=join( pageclass, " " ),
                vcat( innerbody isa AbstractArray ? innerbody : string(innerbody),
                    script(src="https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js")
                )
            );
        kwargs... )
    ]) |> doc
end  # doc( innerhead, innerbody, ie11comp )
