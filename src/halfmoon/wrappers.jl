fns = [
    "ContentWrapper"
]

Core.eval( @__MODULE__,
    """export $(join( vcat(fns, lowercase.(fns)), ", "))""" |> Meta.parse )


makeBasicComponent( "content-wrapper", "div" )


for fn in fns
    # Core.eval( @__MODULE__, """$(lowercase(fn)) = doc ∘ $fn""" |> Meta.parse )
    Core.eval( @__MODULE__, """$(lowercase(fn))( x...; kwargs... ) = $fn( x...; kwargs... ) |> doc""" |> Meta.parse )
end  # for fn in fns
