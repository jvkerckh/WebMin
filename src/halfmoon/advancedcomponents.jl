fns =[
    "Alert", "AlertHeading",
    "Badge", "BadgeGroup",
    "Breadcrumb", "BreadcrumbItem",
    "BtnGroup", "BtnToolbar",
    "CollapsePanel", "CollapseHeader", "CollapseContent", "CollapseGroup",
    "HiddenCollapse",
    "Dropdown", "DropdownMenu", "DropdownHeader", "DropdownItem",
    "DropdownDivider", "DropdownContent",
    "Pagination", "PageItem", "PageLink",
    "HMProgress", "ProgressBar", "ProgressGroup"
]


Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


function Alert( inner=""; tag::AbstractString="div", id="", style::Symbol=:none,
    filled::Symbol=:none, dismissable::Bool=false, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    aclass = ["alert"]
    style ∈ [:primary, :success, :secondary, :danger] && push!( aclass, "alert-$style" )
    filled ∈ [:dm, :lm, :both] && push!( aclass,
        string( "filled", filled === :both ? "" : "-$filled" ) )
    dismissable &&
        (inner = vcat( Button( class="close", data__dismiss="alert",
            type="button", aria__label="Close",
            Span( aria__hidden="true", "&times;" ) ), inner ))
    Tag( tag, inner, id=id, classes=vcat( aclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # Alert( inner; tag, id, style, filled, dismissable, classes, class,
     #   styles, attrs, kwargs... )

makeBasicComponent( "alert-heading", "div" )

function Badge( inner=""; tag::AbstractString="div", id="", style::Symbol=:none,
    pill::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    bclass = ["badge"]
    style ∈ [:primary, :success, :secondary, :danger] &&
        push!( bclass, "badge-$style" )
    pill && push!( bclass, "badge-pill" )
    Tag( tag, inner, id=id, classes=vcat( bclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # Badge( inner; tag, id, style, pill, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "badge-group", "span", role="group" )

function Breadcrumb( inner=""; tag::AbstractString="div", id="",
    align::Symbol=:left, size::Int=0, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    bcclass = ["breadcrumb"]
    align ∈ [:center, :right] && push!( bcclass, "align-$align" )
    size > 0 && push!( bcclass, "font-size-$size" )
    Tag( tag, inner, id=id, classes=vcat( bcclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # Breadcrumb( inner; tag, id, align, size, classes, class, styles, attrs,
     #   kwargs... )


function BreadcrumbItem( inner=""; tag::AbstractString="div", id="",
    active::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    bciclass = ["breadcrumb-item"]
    active && push!( bciclass, "active" )
    Tag( tag, inner, id=id, classes=vcat( bciclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # BreadcrumbItem( inner; tag, id, active, classes, class, styles, attrs,
     #   kwargs... )


function BtnGroup( inner=""; tag::AbstractString="div", id="", size::Symbol=:md,
    vertical::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    bgclass = [string( "btn-group", vertical ? "-vertical" : "" )]
    size ∈ [:sm, :lg] && push!( bgclass, "btn-group-$size" )
    Tag( tag, inner, id=id, classes=vcat( bgclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # BtnGroup( inner; tag, id, active, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "btn-toolbar", "div", role="toolbar" )

CollapsePanel( inner=""; id="", isopen::Bool=false, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Tag( "details", inner, id=id, classes=vcat( "collapse-panel", classes ),
        class=class, styles=styles, attrs=attrs, open=isopen ? "" : nothing;
        kwargs... )

function CollapseHeader( inner=""; tag::AbstractString="div", id="",
    showarrow::Bool=true, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    chclass = ["collapse-header"]
    showarrow || push!( chclass, "without-arrow" )
    Tag( tag, inner, id=id, classes=vcat( chclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # CollapseHeader( inner; tag, id, showarrow, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "collapse-content", "div" )
makeBasicComponent( "collapse-group", "div" )

function HiddenCollapse( openinner, closedinner; tag::AbstractString="span",
    id="", classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    [
        Tag( tag, closedinner, id=id,
            classes=vcat( "hidden-collapse-open", classes ), class=class,
            styles=styles, attrs=attrs; kwargs... )
        Tag( tag, openinner, id=id,
            classes=vcat( "hidden-collapse-closed", classes ), class=class,
            styles=styles, attrs=attrs; kwargs... )
    ]        
end  # HiddenCollapse( openinner, closedinner; tag, id, classes, class, styles,
     #   attrs, kwargs... )


function Dropdown( inner=""; tag::AbstractString="div", id="",
    arrow::Bool=false, dropdir::Symbol=:down, onhover::Bool=false,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    ddclass = ["dropdown"]
    arrow && push!( ddclass, "with-arrow" )
    dropdir ∈ [:up, :right, :left] && push!( ddclass, "drop$dropdir" )
    onhover && push!( ddclass, "toggle-on-hover" )
    Tag( tag, inner, id=id, classes=vcat( ddclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # Dropdown( inner; tag, id, arrow, dropdie, onhover, classes, class,
     #   styles, attrs, kwargs... )


function DropdownMenu( inner=""; tag::AbstractString="div", id="",
    align::Symbol=:default, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    ddmclass = ["dropdown-menu"]
    align ∈ [:up, :center, :right] && push!( ddmclass, "dropdown-menu-$align" )
    Tag( tag, inner, id=id, classes=vcat( ddmclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # DropdownMenu( inner; tag, id, align, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "dropdown-header", "div" )
makeBasicComponent( "dropdown-item", "div" )
makeBasicComponent( "dropdown-divider", "div", noinner=true )
makeBasicComponent( "dropdown-content", "div" )

function Pagination( inner=""; tag::AbstractString="ul", id="",
    rounded::Bool=false, size::Symbol=:md, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    pclass = ["pagination"]
    rounded && push!( pclass, "pagination-rounded" )
    size ∈ [:lg, :sm] && push!( pclass, "pagination-$size" )
    Tag( tag, inner, id=id, classes=vcat( pclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # Pagination( inner; tag, id, rounded, size, classes, class, styles, attrs,
     #   kwargs... )

function PageItem( inner=""; tag::AbstractString="li", id="",
    active::Bool=false, ellipsis::Bool=false, disabled::Bool=false,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    piclass = ["page-item"]
    ellipsis && push!( piclass, "ellipsis" )
    !ellipsis && active && push!( piclass, "active" )
    disabled && push!( piclass, "disabled" )
    Tag( tag, inner, id=id, classes=vcat( piclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # PageItem( inner; tag, id, active, ellipsis, disabled, classes, class,
     #   styles, attrs, kwargs... )

makeBasicComponent( "page-link", "a" )

HMProgress( inner=""; tag::AbstractString="div", id="",
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Tag( tag, inner, id=id, classes=vcat( "progress", classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )

function ProgressBar( inner=""; tag::AbstractString="div", id="",
    currentvalue::Signed=0, minvalue::Signed=0, maxvalue::Signed=100,
    color::Symbol=:none, animated::Bool=false, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    fill = min( 0.0, max( 100.0,
        (100 * currentvalue) / (maxvalue - minvalue) ) )
    pbclass = ["progress-bar"]
    color ∈ [:success, :secondary, :danger] && push!( pbclass, "bg-$color")
    animated && push!( pbclass, "progress-bar-animated" )
    tag = Tag( tag, inner, id=id, classes=vcat( pbclass, classes ), class=class,
        styles=styles, attrs=attrs, aria__valuenow=currentvalue,
        aria__valuemin=minvalue, aria__valuemax=maxvalue; kwargs... )
    fill > 0 && (tag.Styles["width"] = "$(fill)%")
    tag
end  # PageItem( inner; tag, id, currentvalue, minvalue, maxvalue, color,
     #   animated, classes, class, styles, attrs, kwargs... )

makeBasicComponent( "progress-group", "div" )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
