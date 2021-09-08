export  formcontrol, formgroup, formrow, formtext, invalidfeedback, forminline,
        customcontrol, customcheckbox, customradio, customswitch, customfile,
        inputgroup, inputgroupprepend, inputgroupappend, inputgrouptext


function formcontrol( inner=""; tag::AbstractString="input",
    fcsize::Symbol=:default, required::Bool=false, invalid::Bool=false,
    class::AbstractString="", kwargs... )
    fcclass = ["form-control"]
    fcsize ∈ [:lg, :sm] && push!( fcclass, "form-control-$fcsize" )
    invalid && push!( fcclass, "is-invalid" )
    processhmblock( inner, join( fcclass, " " ), tag, class, required=required ? "required" : nothing; kwargs... )
end  # formcontrol( inner; tag, fcsize, required, class, kwargs... )
  
  
function formgroup( inner=""; tag::AbstractString="div", invalid::Bool=false,
    class::AbstractString="", kwargs... )
    fgclass = ["form-group"]
    invalid && push!( fgclass, "is-invalid" )
    processhmblock( inner, join( fgclass, " " ), tag, class; kwargs... )
end  # formgroup( inner; tag, invalid, class, kwargs... )
  
  
formrow( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "form-row", tag, class; kwargs... )
  
formtext( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) = processhmblock( inner, "form-text", tag, class; kwargs... )
  
invalidfeedback( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "invalid-feedback", tag, class; kwargs... )
  
forminline( inner=""; tag::AbstractString="form", fisize::Symbol=:default,
    class::AbstractString="", kwargs... ) =
    processhmblock( inner, string( "form-inline", fisize ∈ [:sm, :md, :lg, :xl] ? "-$fisize" : "" ), tag, class; kwargs... )
  
customcontrol( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "custom-control", tag, class; kwargs... )


function customcheckbox( inner=""; tag::AbstractString="div",
    class::AbstractString="", hstack::Bool=false, kwargs... )
    ccclass = ["custom-checkbox"]
    hstack && push!( ccclass, "d-inline-block" )
    processhmblock( inner, join( ccclass, " " ), tag, class; kwargs... )
end  # customcheckbox( inner; tag, class, hstack, kwargs... )


function customradio( inner=""; tag::AbstractString="div",
    class::AbstractString="", hstack::Bool=false, kwargs... )
    ccclass = ["custom-radio"]
    hstack && push!( ccclass, "d-inline-block" )
    processhmblock( inner, join( ccclass, " " ), tag, class; kwargs... )
end  # customradio( inner; tag, class, hstack, kwargs... )


function customswitch( inner=""; tag::AbstractString="div",
    class::AbstractString="", hstack::Bool=false, kwargs... )
    ccclass = ["custom-switch"]
    hstack && push!( ccclass, "d-inline-block" )
    processhmblock( inner, join( ccclass, " " ), tag, class; kwargs... )
end  # customswitch( inner; tag, class, hstack, kwargs... )


customfile( inner=""; tag::AbstractString="div", class::AbstractString="",
    multiple::Bool=false, kwargs... ) =
    processhmblock( inner, "custom-file", tag, class, multiple=multiple ? "multiple" : nothing; kwargs... )

function inputgroup( inner=""; tag::AbstractString="div",
    igsize::Symbol=:default, class::AbstractString="", kwargs... )
    igclass = ["input-group"]
    igsize ∈ [:sm, :lg] && push!( igclass, "input-group-$igsize" )
    processhmblock( inner, join( igclass, " " ), tag, class; kwargs... )
end  # inputgroup( inner; tag, igsize, class, kwargs... )

inputgroupprepend( inner=""; tag::AbstractString="div",
    class::AbstractString="", kwargs... ) =
    processhmblock( inner, "input-group-prepend", tag, class; kwargs... )

inputgroupappend( inner=""; tag::AbstractString="div",
    class::AbstractString="", kwargs... ) =
    processhmblock( inner, "input-group-append", tag, class; kwargs... )

inputgrouptext( inner=""; tag::AbstractString="div", class::AbstractString="",
    kwargs... ) =
    processhmblock( inner, "input-group-text", tag, class; kwargs... )
