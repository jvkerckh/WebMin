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
abstract type HtmlTag end

export doc, fa, Tag


function doc( htmltag::HtmlTag )
    body = render(htmltag)
    htmltag.tag == "html" ? doc(body) : body
end  # doc( htmltag )

doc( inner::AbstractArray ) = doc.(inner) |> join
doc( body ) = string( "<!DOCTYPE html>\n", body )

function doc( headpart, bodypart )
    (headpart isa NormalTag && headpart.tag == "head") ||
        (headpart = Head(headpart))
    (bodypart isa NormalTag && bodypart.tag == "body") ||
        (bodypart = Body(bodypart))

    Tag( "html", [headpart, bodypart] ) |> doc
end  # doc( headpart, bodypart )


function fa( icon::AbstractString; class::AbstractString="", kwargs... )
    faclass = string( "fa", " fa-", icon, isempty(class) ? "" : " ", class )
    i( class=faclass; kwargs... )
end  # fa( icon; fa5, class, kwargs... )


function Tag( tag::AbstractString, content=""; id="",
    classes::Vector{S}=String[],
    class::AbstractString="",
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    classes = combineclasses!( classes, class )

    if Symbol(tag |> lowercase) ∈ VOID_TAGS
        return VoidTag( tag, id=id, classes=classes, styles=styles, attrs=attrs; kwargs... )
    end  # if Symbol(tag |> lowercase)

    NormalTag( tag, process_content(content), id=id, classes=classes,
        styles=styles, attrs=attrs; kwargs... )
end  # Tag( tag, content; id, classes, styles, attrs, kwargs... )


function makeprefix( htmltag::HtmlTag, tag::AbstractString )
    prefix = ["<$tag"]
    htmltag.id == "" || push!( prefix, string( "id=\"", htmltag.id, "\"" ) )
    isempty(htmltag.classes) || push!( prefix, string( "class=\"",
        join( htmltag.classes, " " ), "\"" ) )
    styles = htmltag.styles
    isempty(styles) || push!( prefix, string( "style=\"",
        join( ["$key: $(styles[key])" for key in keys(styles)], "; " ), "\"" ) )
    attrs = htmltag.attrs
    isempty(attrs) ||
        append!( prefix, [attrs[key] == "" ? "$key" :
            "$key=\"$(attrs[key])\"" for key in keys(attrs)] )
    prefix
end  # makeprefix( htmltag, tag )

makeprefix( htmltag::HtmlTag ) = makeprefix( htmltag, htmltag.tag )

# Internal type to represent a normal string as content of a Html tag
struct Text <: HtmlTag
    content::String

    Text( str::AbstractString ) = new(string(str))
end  # struct Text

render( txt::Text ) = txt.content


# General struct for normal HTML tags.
mutable struct NormalTag <: HtmlTag
    tag::String
    id::String
    classes::Vector{String}
    styles::Dict{String, Any}
    attrs::Dict{String, Any}
    content::Vector{HtmlTag}

    function NormalTag( tag::AbstractString, content::AbstractArray{HtmlTag};
        id="", classes::Vector{S}=String[],
        styles::Dict{String, A1}=Dict{String, Any}(),
        attrs::Dict{String, A2}=Dict{String, Any}(),
        kwargs... ) where {S <: AbstractString, A1, A2}
        newtag = new()
        set_tag( newtag, tag )
        set_attributes( newtag, id=id, classes=classes, styles=styles,
            attrs=attrs; kwargs... )
        newtag.content = deepcopy(content)
        newtag
    end
end  # mutable struct NormalTag

render( htmltag::NormalTag ) = string( join( makeprefix(htmltag), " " ), ">",
    render.(htmltag.content) |> join, "</$(htmltag.tag)>" )


# General struct for void HTML tags.
mutable struct VoidTag <: HtmlTag
    tag::String
    id::String
    classes::Vector{String}
    styles::Dict{String, Any}
    attrs::Dict{String, Any}

    function VoidTag( tag::AbstractString; id="", classes::Vector{S}=String[],
        styles::Dict{String,A1}=Dict{String,Any}(),
        attrs::Dict{String,A2}=Dict{String,Any}(),
        kwargs... ) where {T <: HtmlTag, S <: AbstractString, A1, A2}
        newtag = new()
        set_tag( newtag, tag )
        set_attributes( newtag, id=id, classes=classes, styles=styles,
            attrs=attrs; kwargs... )
        newtag
    end
end  # mutable struct VoidTag

render( htmltag::VoidTag ) = join( push!( makeprefix(htmltag), "/>" ), " " )
render( arr::AbstractArray ) = render.( arr ) |> join


process_content( content::AbstractArray{HT} ) where HT <: HtmlTag =
    Vector{HtmlTag}(content)
process_content( content::HtmlTag ) = HtmlTag[content]
process_content( content::AbstractArray ) = isempty(content) ? HtmlTag[] :
    vcat( process_content.(content)... )
process_content( content ) = Text(content |> string) |> process_content


set_tag( newtag::HtmlTag, tag::AbstractString ) =
    (newtag.tag = tag |> string |> lowercase)

function set_attributes( newtag::HtmlTag; id="",
    classes::Vector{String}=String[],
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    newtag.id = id |> string
    newtag.classes = classes
    newtag.styles = styles |> Dict{String,Any}
    newtag.attrs = process_attrs( attrs |> Dict{String,Any},
        Pair{Symbol,Any}[kwargs...] )

    combineclasses!( newtag.classes, get( newtag.attrs, "class", "" ) )
    delete!( newtag.attrs, "class" )
end  # set_attributes( newtag; id, classes, styles, attrs, kwargs... )


function combineclasses!( classes::Vector{S},
    class::AbstractString ) where S <: AbstractString
    classes = deepcopy(classes)
    isempty(class) || append!( classes, split( class, " " ) )
    filter!( cl -> !isempty(cl), classes ) |> unique! |> Vector{String}
end  # combineclasses!( classes, class )


function process_pars( pars::Dict{String,T},
    kwargs::Vector{Pair{Symbol,Any}} ) where T
    kwargs = Base.map(kwargs) do attrval
        attr = attrval[1] |> string |> lowercase
        attr = replace( attr, "__" => "-" )
        attr = replace( attr,  "!!" => ":" )
        attr = replace( attr, "!" => "." )
        Pair{String,Any}( attr, attrval[2] )
    end # Base.map(kwargs) do attrval

    for par in keys(pars)
        push!( kwargs, lowercase(par |> strip) => pars[par] )
    end  # for par in keys(pars)

    filter!( kwarg -> !isnothing(kwarg[2]), kwargs )
    join( [string( " ", kwarg[1], "=\"", kwarg[2], "\"" ) for kwarg in kwargs] )
end  # process_pars( pars, kwargs )


function process_attrs( attrs::Dict{String, T},
    kwargs::Vector{Pair{Symbol, Any}} ) where T
    attrs = Dict{String,Any}(lowercase(attr[1] |> strip) => attr[2] for attr in attrs)

    for kwarg in kwargs
        attr = kwarg[1] |> string |> lowercase
        attr = replace( attr, "__" => "-" )
        attr = replace( attr,  "!!" => ":" )
        attr = replace( attr, "!" => "." )
        attrs[attr] = kwarg[2]
    end

    filter!( attr -> !isnothing(attr[2]), attrs )
end  # process_attrs( attrs, kwargs )


function normal_tag( tag::String, child, pars::Dict{String,T},
    kwargs::Vector{Pair{Symbol,Any}} ) where T
    string( "<", tag, process_pars( pars, kwargs ), ">",
        child isa AbstractArray ? join(child) : child, "</", tag, ">" )
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
    tag === :html && return  # Can't define Html inside module Html
    
    ctag = tag |> string |> uppercasefirst
    Core.eval( @__MODULE__, """$ctag( content=""; id="", classes::Vector{S}=String[], styles::Dict{String, A1}=Dict{String, Any}(), attrs::Dict{String, A2}=Dict{String, Any}(), kwargs... ) where {S <: AbstractString, A1, A2} = Tag( $tag |> string, content, id=id, classes=classes, styles=styles, attrs=attrs; kwargs... )""" |> Meta.parse )

    Core.eval(@__MODULE__, "export $ctag" |> Meta.parse )
end  # register_normal_tag( tag )


function register_void_tag( tag::Symbol )
    Core.eval( @__MODULE__, """function $tag( pars::Dict{String,T}=Dict{String,Any}(); kwargs... ) where T
        void_tag( "$tag", pars, Pair{Symbol,Any}[kwargs...] )
    end""" |> Meta.parse )

    Core.eval( @__MODULE__, "export $tag" |> Meta.parse )
    tag ∈ [:base, :meta] && return

    ctag = tag |> string |> uppercasefirst
    Core.eval( @__MODULE__, """$ctag( ; id="", classes::Vector{S}=String[], styles::Dict{String, A1}=Dict{String, Any}(), attrs::Dict{String, A2}=Dict{String, Any}(), kwargs... ) where {T <: HtmlTag, S <: AbstractString, A1, A2} = VoidTag( $tag |> string, id=id, classes=classes, styles=styles, attrs=attrs; kwargs... )""" |> Meta.parse )

    Core.eval( @__MODULE__, "export $ctag" |> Meta.parse )
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
