fns = [
    "FormControl", "FormGroup", "FormRow", "FormText", "InvalidFeedback",
    "FormInline",
    "CustomControl", "CustomCheckbox", "CustomRadio", "CustomSwitch",
    "CustomFile",
    "InputGroup", "InputGroupPrepend", "InputGroupAppend", "InputGroupText"
]

Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


function FormControl( inner=""; tag::AbstractString="input", id="",
    size::Symbol=:default, required::Bool=false, invalid::Bool=false,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    fcclass = ["form-control"]
    size ∈ [:lg, :sm] && push!( fcclass, "form-control-$size" )
    invalid && push!( fcclass, "is-invalid" )
    Tag( tag, inner, id=id, classes=vcat( fcclass, classes ), class=class,
        styles=styles, attrs=attrs, required=required ? "required" : nothing;
        kwargs... )
end  # FormControl( inner; tag, id, size, required, invalid, classes, class,
     #   styles, attrs, kwargs... )


function FormGroup( inner=""; tag::AbstractString="div", id="",
    invalid::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    fgclass = ["form-group"]
    invalid && push!( fgclass, "is-invalid" )
    Tag( tag, inner, id=id, classes=vcat( fgclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # FormGroup( inner; tag, id, invalid, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "form-row", "div" )
makeBasicComponent( "form-text", "div" )
makeBasicComponent( "invalid-feedback", "div" )
makeBasicComponent( "form-inline", "form" )
makeBasicComponent( "custom-control", "div" )

function CustomCheckbox( inner=""; tag::AbstractString="div", id="",
    hstack::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    ccclass = ["custom-checkbox"]
    hstack && push!( ccclass, "d-inline-block" )
    Tag( tag, inner, id=id, classes=vcat( ccclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # CustomCheckbox( inner; tag, id, hstack, classes, class, styles, attrs,
     #   kwargs... )


function CustomRadio( inner=""; tag::AbstractString="div", id="",
    hstack::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    crclass = ["custom-radio"]
    hstack && push!( crclass, "d-inline-block" )
    Tag( tag, inner, id=id, classes=vcat( crclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # CustomRadio( inner; tag, id, hstack, classes, class, styles, attrs,
     #   kwargs... )


function CustomSwitch( inner=""; tag::AbstractString="div", id="",
    hstack::Bool=false, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    csclass = ["custom-switch"]
    hstack && push!( csclass, "d-inline-block" )
    Tag( tag, inner, id=id, classes=vcat( csclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # CustomSwitch( inner; tag, id, hstack, classes, class, styles, attrs,
     #   kwargs... )

CustomFile( inner=""; tag::AbstractString="div", id="", multiple::Bool=false,
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2} =
    Tag( tag, inner, id=id, classes=vcat( "custom-file", classes ),
        class=class, styles=styles, attrs=attrs,
        multiple=multiple ? "multiple" : nothing; kwargs... )


function InputGroup( inner=""; tag::AbstractString="div", id="",
    size::Symbol=:default, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    igclass = ["input-group"]
    size ∈ [:sm, :lg] && push!( igclass, "input-group-$size" )
    Tag( tag, inner, id=id, classes=vcat( igclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # InputGroup( inner; tag, id, size, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "input-group-prepend", "div" )
makeBasicComponent( "input-group-append", "div" )
makeBasicComponent( "input-group-text", "div" )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
