export StaticStickyAlert, JSStickyAlert

abstract type HMStickyAlert <: Html.HtmlTag end
Html.doc( stickyalert::HMStickyAlert ) = Html.render(stickyalert)


mutable struct StaticStickyAlert <: HMStickyAlert
    id::String
    alertType::Symbol
    fillType::Symbol
    classes::Vector{String}
    styles::Dict{String, Any}
    attrs::Dict{String, Any}
    content::Vector{Html.HtmlTag}

    function StaticStickyAlert( id, content::AbstractArray{Html.HtmlTag};
        alertType::Symbol=:default, fillType::Symbol=:default,
        classes::Vector{S}=String[],
        styles::Dict{String, A1}=Dict{String, Any}(),
        attrs::Dict{String, A2}=Dict{String, Any}(),
        kwargs... ) where {S <: AbstractString, A1, A2}
        newsa = new()
        newsa.alertType = alertType = alertType ∈ [:primary, :success, :secondary, :danger] ? alertType : :default
        newsa.fillType = fillType = fillType ∈ [:dm, :lm, :all] ? fillType :
            :default
        saclass = ["alert"]
        alertType === :default || push!( saclass, "alert-$alertType" )
        fillType === :default ||
            (fillType === :all ? push!( saclass, "filled" ) : push!( saclass, "filled-$fillType" ) )
        Html.set_attributes( newsa, id=id, classes=vcat( saclass, classes ),
            styles=styles, attrs=attrs, role="alert"; kwargs... )
        newsa.content = deepcopy(content)
        newsa
    end  # StaticStickyAlert( id, content; alertType, fillType, classes,
         #   styles, attrs, kwargs... )
end  # StaticStickyAlert

StaticStickyAlert( id, content=""; alertType::Symbol=:default,
    fillType::Symbol=:default, classes::Vector{S}=String[],
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    StaticStickyAlert( id, Html.process_content(content), alertType=alertType,
        fillType=fillType, classes=classes, styles=styles, attrs=attrs;
        kwargs... )

convertSA( stickyalert::StaticStickyAlert ) =
    Div( stickyalert.content, id=stickyalert.id, styles=stickyalert.styles,
        classes=stickyalert.classes, attrs=stickyalert.attrs )

Html.render( stickyalert::StaticStickyAlert ) = stickyalert |> convertSA |> doc


mutable struct JSStickyAlert <: HMStickyAlert
    fname::String
    content::String
    title::String
    alertType::Symbol
    fillType::Symbol
    hasDismissButton::Bool
    timeShown::Int

    function JSStickyAlert( fname::AbstractString, content::AbstractString,
        title::AbstractString; static::Bool=true, alertType::Symbol=:default,
        fillType::Symbol=:default, hasDismissButton::Bool=true,
        timeShown::Integer=5000 )
        newsa = new()
        newsa.fname = fname
        newsa.content = static ? "\"$content\"" : content
        newsa.title = title
        newsa.alertType = alertType ∈ [:primary, :success, :secondary, :danger] ? alertType : :default
        newsa.fillType = fillType ∈ [:lm, :dm, :all] ? fillType : :default
        newsa.hasDismissButton = hasDismissButton
        newsa.timeShown = max( 0, timeShown )
        newsa
    end  # JSStickyAlert( fname, content, title; static, alertType, fillType,
         #   hasDismissButton, timeShown )
end  # JSStickyAlert

function Html.render( stickyalert::JSStickyAlert )
    alertType = stickyalert.alertType
    alertType = alertType === :default ? "" : "alert-$alertType"
    fillType = stickyalert.fillType
    fillType = fillType === :default ? "" :
        (fillType === :all ? "filled" : "filled-$fillType")
    
    """$(stickyalert.fname): function $(stickyalert.fname)() {
      halfmoon.initStickyAlert({
        content: $(stickyalert.content),
        title: "$(stickyalert.title)",
        alertType: "$alertType",
        fillType: "$fillType",
        hasDismissButton: $(stickyalert.hasDismissButton),
        timeShown: $(stickyalert.timeShown)
      })
    }"""
end  # render( stickyalert )
