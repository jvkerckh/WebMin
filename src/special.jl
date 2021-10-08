notfound = function ( req::Request )
    res = html( [
        head(link( rel="stylesheet", href="https://www.w3schools.com/w3css/4/w3.css" ))
        body( class="w3-pale-red", Html.div( [
            h1("Error 404 - Lost up the creek without a paddle...")
            p( class="w3-padding-large", [
                "This is embarrassing, we can't find "
                span( style="font-weight: bold", req.target )
                " ... We seem to have misplaced the page you're looking for"
            ] )
        ] ) )
    ]) |> doc
    Response( 404; body=res )
end  # notfound

route( "/", notfound )
route( "/*", notfound )
