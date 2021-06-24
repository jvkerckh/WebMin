module WebMin

using HTTP
using JSON
using Sockets

using Reexport

export Request, Response, HTTPStream, WebSocket
const Request = HTTP.Request
const Response = HTTP.Response
const HTTPStream = HTTP.Stream
const WebSocket = HTTP.WebSockets.WebSocket

include("server.jl")
include("html.jl")
include("render.jl")
include("websockets.jl")
include("wsroutes.jl")
include("router.jl")
include("cookies.jl")

include("special.jl")

end  # module WebMin
