using Sockets
using HTTP

const SERVER = Sockets.listen(Sockets.InetAddr(parse(IPAddr, "127.0.0.1"), 8000))
const ROUTER = HTTP.Router()

function logoutgethandler(req::HTTP.Request)
    println(req)
    html = """<!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8" />
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
            <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" name="viewport" />
            <meta name="viewport" content="width=device-width" />
    <title>Logout</title>
    <script type="text/javascript">
        window.location.href = window.location.protocol + '//' + window.location.hostname + ':' +  window.location.port;
    </script>
    </head>
    <body>
    </body>
    </html>"""
    HTTP.Response(200, ["Set-Cookie" => "sessionid="]; body=html)
end

function logingethandler(req::HTTP.Request)
    if HTTP.hasheader(req, "Cookie") && contains(HTTP.header(req, "Cookie"), "sessionid=150POLrulez")
        roothandler(req)
    else
        html = """<!DOCTYPE html>
        <html lang="en" class="auto-scaling-disabled">
        
        <head>
            <!-- Meta tags -->
            <meta charset="utf-8" />
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
            <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" name="viewport" />
            <meta name="viewport" content="width=device-width" />
        
            <!-- Favicon and title -->
            <link rel="shortcut icon" type="image/x-icon" href="favicon.ico" />
            <title>CARE Solutions</title>
        
            <!-- Halfmoon CSS -->
            <link href="https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon-variables.min.css" rel="stylesheet" />
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@5.9.55/css/materialdesignicons.min.css" />
        
        </head>
        
        <body data-dm-shortcut-enabled="true" data-set-preferred-mode-onload="true">
            <div class="page-wrapper">
                <div class="content-wrapper">
                    <div class="w-full h-full d-flex justify-content-center align-items-center">
                        <div class="card w-400 mw-full">
                            <div class="position-absolute top-0 right-0 z-10 p-10">
                                <button class="btn btn-square" type="button" onclick="halfmoon.toggleDarkMode()">
                                    <i class="mdi mdi-moon-last-quarter"></i>
                                </button>
                            </div>
                            <div class="d-flex justify-content-center">
                                <img class="h-50 hidden-lm" src="logo-rma-white.png" />
                                <img class="h-50 hidden-dm" src="logo-rma.png" />
                            </div>
                            <h2 class="card-title text-center">
                                CARE Solutions
                            </h2>
                            <form action="/login" method="post">
                                <div class="form-group input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="mdi mdi-email-outline"></i>
                                        </span>
                                    </div>
                                    <input type="email" id="email" class="form-control" required="required" />
                                </div>
                                <div class="form-group input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="mdi mdi-key-outline"></i>
                                        </span>
                                    </div>
                                    <input type="password" id="password" class="form-control" required="required" />
                                </div>
                                <input class="btn btn-primary btn-block" type="submit" value="Login" />
                                <div class="text-center font-size-12 mt-10">
                                    <a href="#">Reset password</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <script src="https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js"></script>
        </body>
        
        </html>"""
        HTTP.Response(200,  ["Set-Cookie" => "sessionid="]; body=html)
    end
end

function loginposthandler(req::HTTP.Request)
    println(req)
    html = """<!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8" />
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
            <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" name="viewport" />
            <meta name="viewport" content="width=device-width" />
    <title>Login</title>
    <script type="text/javascript">
        window.location.href = window.location.protocol + '//' + window.location.hostname + ':' +  window.location.port;
    </script>
    </head>
    <body>
    </body>
    </html>"""
    HTTP.Response(200, ["Set-Cookie" => "sessionid=150POLrulez; Max-Age=86400; Secure; HttpOnly; SameSite=Strict"]; body=html)
end

function roothandler(req::HTTP.Request)
    println(req)
    if HTTP.hasheader(req, "Cookie") && contains(HTTP.header(req, "Cookie"), "sessionid=150POLrulez")
        html = """<!DOCTYPE html>
        <html lang="en" class="auto-scaling-disabled">
        
        <head>
            <!-- Meta tags -->
            <meta charset="utf-8" />
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
            <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" name="viewport" />
            <meta name="viewport" content="width=device-width" />
        
            <!-- Favicon and title -->
            <link rel="shortcut icon" type="image/x-icon" href="favicon.ico">
            <title>CARE Solutions</title>
        
            <!-- Halfmoon CSS -->
            <link href="https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon-variables.min.css" rel="stylesheet" />
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@5.9.55/css/materialdesignicons.min.css" />
        </head>
        
        <body class="with-custom-webkit-scrollbars with-custom-css-scrollbars" data-dm-shortcut-enabled="true"
            data-sidebar-shortcut-enabled="true" data-set-preferred-mode-onload="true">
            <!-- Modals go here -->
        
            <div class="page-wrapper with-navbar with-sidebar" data-sidebar-type="overlayed-sm-and-down">
        
                <div class="sticky-alerts"></div>
        
                <!-- Navbar start -->
                <nav class="navbar">
                    <div class="navbar-content mr-10">
                        <button class="btn btn-action" type="button" onclick="halfmoon.toggleSidebar()">
                            <i class="mdi mdi-menu"></i>
                        </button>
                    </div>
                    <a href="#" class="navbar-brand ml-20">
                        <img class="h-50 hidden-lm" src="logo-rma-white.png">
                        <img class="h-50 hidden-dm" src="logo-rma.png">
                    </a>
                    <span class="navbar-brand ml-auto hidden-sm-and-down">
                        CARE Solutions
                    </span>
                    <div class="navbar-content ml-auto">
                        <div class="dropdown with-arrow">
                            <button class="btn" data-toggle="dropdown" type="button" id="navbar-dropdown-toggle-btn-1">
                                LCL Ben LAUWENS
                                <i class="mdi mdi-chevron-down"></i>
                            </button>
                            <div class="dropdown-menu w-200">
                                <a href="#" class="dropdown-item sidebar-link-with-icon">
                                    <span class="sidebar-icon"><i class="mdi mdi-account-cog-outline"></i></span>
                                    Preferences</a>
                                <a href="/logout" class="dropdown-item sidebar-link-with-icon">
                                    <span class="sidebar-icon"><i class="mdi mdi-logout"></i></span>
                                    Logout</a>
                            </div>
                        </div>
                        <button class="btn btn-action ml-10" type="button" onclick="halfmoon.toggleDarkMode()">
                            <i class="mdi mdi-moon-last-quarter"></i>
                        </button>
                    </div>
                </nav>
        
                <div class="sidebar-overlay" onclick="halfmoon.toggleSidebar()"></div>
        
                <div class="sidebar">
                    <div class="sidebar-menu">
                        <div class="sidebar-content hidden-sm-and-down">
                            <input id="search-page-input" type="text" class="form-control" placeholder="Search">
                            <div class="mt-10 font-size-12">
                                Press <kbd>F</kbd> to focus
                            </div>
                        </div>
                        <h5 class="sidebar-title">Dashboard</h5>
                        <div class="sidebar-divider"></div>
                        <a href="#" class="sidebar-link sidebar-link-with-icon active">
                            <span class="sidebar-icon">
                                <i class="mdi mdi-view-dashboard-outline"></i>
                            </span>
                            Overview
                        </a>
                        <br />
                        <h5 class="sidebar-title">Administration</h5>
                        <div class="sidebar-divider"></div>
                        <a href="#" class="sidebar-link sidebar-link-with-icon">
                            <span class="sidebar-icon">
                                <i class="mdi mdi-book-outline"></i>
                            </span>
                            Courses
                        </a>
                        <a href="#" class="sidebar-link sidebar-link-with-icon">
                            <span class="sidebar-icon">
                                <i class="mdi mdi-school-outline"></i>
                            </span>
                            Programme
                        </a>
                        <br />
                    </div>
                </div>
        
                <!-- Content wrapper start -->
                <div class="content-wrapper">
                    <!--
                Add your page's main content here
                Examples:
                1. https://www.gethalfmoon.com/docs/content-and-cards/#building-a-page
                2. https://www.gethalfmoon.com/docs/grid-system/#building-a-dashboard
              -->
                </div>
                <!-- Content wrapper end -->
        
            </div>
            <script src="https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js"></script>
            <script type="text/javascript">
                /* Things to do once the DOM is loaded */
                document.addEventListener("DOMContentLoaded", function () {
                    // Getting the repository search input
                    var searchRepoInputElem = document.getElementById("search-page-input");
        
                    // Handle keydown events (overridden)
                    halfmoon.keydownHandler = function (event) {
                        event = event || window.event;
                        // Shortcuts are triggered only if no input, textarea, or select has focus
                        if (!(document.querySelector("input:focus") || document.querySelector("textarea:focus") || document.querySelector("select:focus"))) {
                            // Focus the repository search input when [/] is pressed
                            if (event.which == 70) {
                                if (halfmoon.pageWrapper) {
                                    if (halfmoon.pageWrapper.getAttribute("data-sidebar-hidden")) {
                                        halfmoon.pageWrapper.removeAttribute("data-sidebar-hidden");
                                    }
                                    searchRepoInputElem.focus();
                                    event.preventDefault();
                                }
                            }
                        }
                        // You can handle other keydown events here using if or else-if statements
                    }
                });
            </script>
            <script>
                let websocket = new WebSocket(window.location.protocol.replace('http', 'ws') + '//' + window.location.hostname + ':' +  window.location.port + '/ws');
                websocket.onopen = function (event) {
                    websocket.send("Here's some text that the server is urgently awaiting!");
                };
                websocket.onmessage = function(event) {
                    halfmoon.initStickyAlert({
                        content: event.data,      // Required, main content of the alert, type: string (can contain HTML)
                        title: "Default alert"      // Optional, title of the alert, default: "", type: string
                    });
                };
            </script>
        </body>
        </html>"""
        HTTP.Response(200, html)
    else
        logingethandler(req)
    end
end

function logohandler(http::HTTP.Stream, ext="")
    HTTP.setheader(http, "Content-Type" => "image/png")
    startwrite(http)
    open(string("logo-rma", ext, ".png")) do io
        while !eof(io)
            write(http, readavailable(io))
        end
    end
end

function icohandler(http::HTTP.Stream)
    HTTP.setheader(http, "Content-Type" => "image/x-icon")
    startwrite(http)
    open("favicon.ico") do io
        while !eof(io)
            write(http, readavailable(io))
        end
    end
end

function websockethandler(http::HTTP.Stream)
        HTTP.WebSockets.upgrade(http; binary=false) do ws
            for field in ws |> typeof |> fieldnames
                println( field, " ==> ", getfield(ws, field) )
            end
        
            while !eof(ws)
                try
                    data = readavailable(ws)
                    println(String(data))
                    write(ws, "Hello WebSocket World!")
                catch exc
                end
            end

            println( "Can we get here?" )
        end
end

HTTP.@register(ROUTER, "GET", "/logo-rma.png", HTTP.StreamHandlerFunction((stream) -> logohandler(stream)))
HTTP.@register(ROUTER, "GET", "/logo-rma-white.png", HTTP.StreamHandlerFunction((stream) -> logohandler(stream, "-white")))
HTTP.@register(ROUTER, "GET", "/login", logingethandler)
HTTP.@register(ROUTER, "GET", "/logout", logoutgethandler)
HTTP.@register(ROUTER, "POST", "/login", loginposthandler)
HTTP.@register(ROUTER, "GET", "/", roothandler)
HTTP.@register(ROUTER, "GET", "/favicon.ico", HTTP.StreamHandlerFunction(icohandler))
HTTP.@register(ROUTER, "GET", "/ws", HTTP.StreamHandlerFunction(websockethandler))

@async HTTP.serve(ROUTER; server=SERVER)
