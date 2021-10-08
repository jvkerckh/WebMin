fns = [
    "Container",
    "Content", "ContentTitle",
    "Card", "CardTitle",
    "Row", "HMCol", "HMCols"
]

Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


function Container( inner=""; tag::AbstractString="div", id="",
    size::Symbol=:fluid, classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    size ∈ [:fluid, :sm, :md, :lg, :xl] || (size = :fluid)
    Tag( tag, inner, id=id, classes=vcat( "container-$size", classes ),
        class=class, styles=styles, attrs=attrs, kwargs... )
end  # Container( inner; tag, id, size, classes, class, styles, attrs,
     #   kwargs... )

makeBasicComponent( "content", "div" )
makeBasicComponent( "content-title", "div" )
makeBasicComponent( "card", "div" )
makeBasicComponent( "card-title", "div" )
makeBasicComponent( "row", "div" )

function HMCol( inner=""; tag::AbstractString="div", id="", size::Symbol=:none,
    auto::Bool=false, ncols::Integer=0, classes::Vector{S}=String[],
    class::AbstractString="", styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    auto || return HMCols( inner, tag=tag, id=id, size=[size], ncols=[ncols],
        classes=classes, class=class, styles=styles, attrs=attrs; kwargs... )
    size ∈ [:sm, :md, :lg, :xl] || (size = :none)
    hmclass = string( "col", size === :none ? "" : "-$size", "-auto" )
    Tag( tag, inner, id=id, classes=vcat( hmclass, classes ), class=class,
        styles=styles, attrs=attrs; kwargs... )
end  # HMCol( inner; tag, id, size, auto, ncols, classes, class, styles, attrs,
     #   kwargs... )


function HMCols( inner=""; tag::AbstractString="div", id="",
    size::Vector{Symbol}=[:none], ncols::Vector{T}=[0],
    classes::Vector{S}=String[], class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {T <: Integer, S <: AbstractString, A1, A2}
    if length(size) != length(ncols)
        @warn "Size vector and columns vector must have equal lengths."
        return ""
    end  # if length(size) != length(ncols)

    isempty(size) && return ""
    hmclass = map( eachindex(size) ) do ii
        string( "col", size[ii] ∈ [:sm, :md, :lg, :xl] ? "-$(size[ii])" : "",
            1 <= ncols[ii] <= 11 ? "-$(ncols[ii])" : "" )
    end

    Tag( tag, inner, id=id, classes=vcat( hmclass, classes ), class=class, styles=styles, attrs=attrs; kwargs... )
end  # HMCols( inner; tag, id, size, ncols, classes, class, styles, attrs,
     #   kwargs... )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
