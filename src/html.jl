@reexport module Html

const NORMAL_TAGS = [
    :html,
    :head, :style, :title,
    :body,
    :address, :article, :aside, :footer, :header, :h1, :h2, :h3, :h4, :h5, :h6, :main, :nav, :section,
    :blockquote, :dd, :div, :dl, :dt, :figcaption, :figure, :li, :ol, :p, :pre, :ul,
    :a, :abbr, :b, :bdi, :bdo, :cite, :code, :data, :dfn, :em, :i, :kbd, :mark, :q, :rb, :rp, :rt, :rtc, :ruby, :s, :samp, :small, :span, :strong, :sub, :sup, :time, :u, :var,
    :audio, :map, :video,
    :iframe, :object, :picture, :portal,
    :svg, :mathml,
    :canvas, :noscript, :script,
    :del, :ins,
    :caption, :colgroup, :table, :tbody, :td, :tfoot, :th, :thead, :tr,
    :button, :datalist, :fieldset, :form, :label, :legend, :meter, :optgroup, :option, :output, :progress, :select, :textarea,
    :details, :dialog, :menu, :summary,
    :slot, :template
]
const VOID_TAGS = [
    :base, :link, :meta,
    :hr,
    :br, :wbr,
    :area, :img, :track,
    :embed, :param, :source,
    :col,
    :input
]


export doc, fa


function doc( body::AbstractString )
    string( "<!DOCTYPE html>\n", body )
end  # doc( body )


function fa( icon::AbstractString; class::AbstractString="", kwargs... )
    faclass = string( "fa", " fa-", icon, isempty(class) ? "" : " ", class )
    i( class=faclass; kwargs... )
end  # fa( icon; fa5, class, kwargs... )


function process_pars( pars::Dict{String,T},
    kwargs::Vector{Pair{Symbol,Any}} ) where T
    kwargs = Base.map(kwargs) do attrval
        attr = attrval[1] |> string
        attr = replace( attr, "__" => "-" )
        attr = replace( attr,  "!!" => ":" )
        attr = replace( attr, "!" => "." )
        Pair{String,Any}( attr, attrval[2] )
    end # Base.map(kwargs) do attrval

    for par in keys(pars)
        push!( kwargs, par => pars[par] )
    end  # for par in keys(pars)

    filter!( kwarg -> !isnothing(kwarg[2]), kwargs )
    join( [string( " ", kwarg[1], "=\"", kwarg[2], "\"" ) for kwarg in kwargs] )
end  # process_pars( pars, kwargs )


function normal_tag( tag::String, child, pars::Dict{String,T},
    kwargs::Vector{Pair{Symbol,Any}} ) where T
    string( "<", tag, process_pars( pars, kwargs ), ">", child isa AbstractArray ? join(child) : child, "</", tag, ">" )
end  # normal_tag( tag, child, pars, kwargs )


function void_tag( tag::String, pars::Dict{String,T},
    kwargs::Vector{Pair{Symbol,Any}} ) where T
    string( "<", tag, process_pars( pars, kwargs ), " />" )
end  # void_tag( tag, pars, kwargs )


function register_normal_tag( tag::Symbol )
    Core.eval( @__MODULE__, """function $tag( inner="", pars::Dict{String,T}=Dict{String,Any}(); kwargs... ) where T
        normal_tag( "$tag", inner, pars, Pair{Symbol,Any}[kwargs...] )
    end""" |> Meta.parse )

    Core.eval( @__MODULE__, """function $tag( pars::Dict{String,T}, inner=""; kwargs... ) where T
        normal_tag( "$tag", inner, pars, Pair{Symbol,Any}[kwargs...] )
    end""" |> Meta.parse )

    tag === :map || Core.eval(@__MODULE__, "export $tag" |> Meta.parse )
end  # register_normal_tag( tag )


function register_void_tag( tag::Symbol )
    Core.eval( @__MODULE__, """function $tag( pars::Dict{String,T}=Dict{String,Any}(); kwargs... ) where T
        void_tag( "$tag", pars, Pair{Symbol,Any}[kwargs...] )
    end""" |> Meta.parse )

    Core.eval(@__MODULE__, "export $tag" |> Meta.parse )
end  # register_void_tag( tag )


function register_tags()
    for tag in NORMAL_TAGS
        register_normal_tag(tag)
    end  # for tag in NORMAL_TAGS

    for tag in VOID_TAGS
        register_void_tag(tag)
    end  # for tag in VOID_TAGS
end  # register_tags()

register_tags()

end  # module Html

export div
