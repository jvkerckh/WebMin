export  contentwrapper


contentwrapper( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "content-wrapper", tag, class; kwargs... )
