fns = [
    "Modal",
    "ModalDialog", "ModalContent", "ModalTitle", "OpenModalButton",
    "CloseModalButton"
]


Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


mutable struct Modal <: Html.HtmlTag
    id::String
    classes::Vector{String}
    styles::Dict{String, Any}
    attrs::Dict{String, Any}
    content::Vector{Html.HtmlTag}

    function Modal( content::AbstractArray{Html.HtmlTag}; id="",
        classes::Vector{S}=String[],
        styles::Dict{String, A1}=Dict{String, Any}(),
        attrs::Dict{String, A2}=Dict{String, Any}(),
        overlaydismiss::Bool=true, escdismiss::Bool=true,
        iescrollfix::Bool=false, kwargs... ) where {S <: AbstractString, A1, A2}
        newmodal = new()
        mclass = ["modal"]
        iescrollfix && push!( mclass, "ie-scroll-fix" )
        Html.set_attributes( newmodal, id=id, classes=vcat( mclass, classes ),
            styles=styles, attrs=attrs, role="dialog",
            data__overlay__dismissal__disabled=overlaydismiss ? nothing : true,
            data__esc__dismissal__disabled=escdismiss ? nothing : true;
            kwargs... )
        newmodal.content = deepcopy(content)
        newmodal
    end
end  # Modal

Modal( content=""; id="", classes::Vector{S}=String[],
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Modal( Html.process_content(content), id=id, classes=classes,
        styles=styles, attrs=attrs; kwargs... )

Html.doc( modal::Modal ) = Html.render(modal)
Html.render( modal::Modal ) = string( join( makeprefix(modal), " " ), ">",
    Html.render.(modal.content) |> join, "</div>" )
makeprefix( modal::Modal ) = Html.makeprefix( modal, "div" )

makeBasicComponent( "modal-dialog", "div", role="document" )

function ModalContent( inner=""; tag::AbstractString="div", id="",
    mediacontent::Bool=false, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    mcclass = ["modal-content"]
    mediacontent && push!( mcclass, modal-content-media )
    Tag( tag, inner, id=id, classes=vcat( mcclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # ModalContent( inner; tag, id, mediacontent, classes, class, styles,
     #   attrs, kwargs... )

makeBasicComponent( "modal-title", "div" )

OpenModalButton( inner=""; id="", target::AbstractString="",
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Btn( inner, id=id, classes=classes, class=class, styles=styles,
        attrs=attrs, data__toggle="modal",
        data__target = isempty(target) ? nothing : target; kwargs... )


CloseModalButton( inner=""; tag::AbstractString="button", id="",
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Tag( tag, inner, id=id, classes=vcat( "close", classes ), class=class,
        styles=styles, attrs=attrs, data__dismiss="modal", type="button";
        kwargs... )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
