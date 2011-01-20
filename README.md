## Intro

I created this little web server script to test curl's behaviour when it comes to following redirects.  [RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) (or, more accurately RFCs 2068 and 1945) states that user agents aren't supposed to change the http method in response to a 302.

>  10.3.3 302 Found
>  
>  **snipped**
>  
>  Note: RFC 1945 and RFC 2068 specify that the client is not allowed
>  to change the method on the redirected request.  However, most
>  existing user agent implementations treat 302 as if it were a 303
>  response, performing a GET on the Location field-value regardless
>  of the original request method. The status codes 303 and 307 have
>  been added for servers that wish to make unambiguously clear which
>  kind of reaction is expected of the client.

## Testing the behaviour with curl

While it appears that most browsers change the method to a GET it's possible to control the behaviour with cURL.

### Default behaviour when POSTing data with cURL

Note the warning in the response, "Violate RFC 2616/10.3.3 and switch from POST to GET".

    $ curl http://localhost:4567/collection -d"foo=bar" -v -L
    
    * About to connect() to localhost port 4567 (#0)
    *   Trying ::1... Connection refused
    *   Trying fe80::1... Connection refused
    *   Trying 127.0.0.1... connected
    * Connected to localhost (127.0.0.1) port 4567 (#0)
    > POST /collection HTTP/1.1
    > User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
    > Host: localhost:4567
    > Accept: */*
    > Content-Length: 7
    > Content-Type: application/x-www-form-urlencoded
    > 
    < HTTP/1.1 302 Moved Temporarily
    < Location: http://localhost:4567/added
    < Content-Type: text/html;charset=utf-8
    < Content-Length: 0
    < Connection: keep-alive
    < Server: thin 1.2.7 codename No Hup
    < 
    * Connection #0 to host localhost left intact
    * Issue another request to this URL: 'http://localhost:4567/added'
    * Violate RFC 2616/10.3.3 and switch from POST to GET
    * Re-using existing connection! (#0) with host localhost
    * Connected to localhost (127.0.0.1) port 4567 (#0)
    > GET /added HTTP/1.1
    > User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
    > Host: localhost:4567
    > Accept: */*
    > 
    < HTTP/1.1 200 OK
    < Content-Type: text/html;charset=utf-8
    < Content-Length: 32
    < Connection: keep-alive
    < Server: thin 1.2.7 codename No Hup
    < 
    * Connection #0 to host localhost left intact
    * Closing connection #0

### Force strict behaviour when POSTing data with cURL

We no longer get a warning but we receive a 404 because our little server isn't configured to respond to POST requests to /added.

    $ curl http://localhost:4567/collection -d"foo=bar" -v -L --post302
    
    * About to connect() to localhost port 4567 (#0)
    *   Trying ::1... Connection refused
    *   Trying fe80::1... Connection refused
    *   Trying 127.0.0.1... connected
    * Connected to localhost (127.0.0.1) port 4567 (#0)
    > POST /collection HTTP/1.1
    > User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
    > Host: localhost:4567
    > Accept: */*
    > Content-Length: 7
    > Content-Type: application/x-www-form-urlencoded
    > 
    < HTTP/1.1 302 Moved Temporarily
    < Location: http://localhost:4567/added
    < Content-Type: text/html;charset=utf-8
    < Content-Length: 0
    < Connection: keep-alive
    < Server: thin 1.2.7 codename No Hup
    < 
    * Connection #0 to host localhost left intact
    * Issue another request to this URL: 'http://localhost:4567/added'
    * Re-using existing connection! (#0) with host localhost
    * Connected to localhost (127.0.0.1) port 4567 (#0)
    > POST /added HTTP/1.1
    > User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
    > Host: localhost:4567
    > Accept: */*
    > Content-Length: 7
    > Content-Type: application/x-www-form-urlencoded
    > 
    < HTTP/1.1 404 Not Found
    < X-Cascade: pass
    < Content-Type: text/html;charset=utf-8
    < Content-Length: 415
    < Connection: keep-alive
    < Server: thin 1.2.7 codename No Hup
    < 
    * Connection #0 to host localhost left intact
    * Closing connection #0
    
### Odd behaviour when POSTing data with cURL

Note that we still get the "Violate RFC 2616/10.3.3 and switch from POST to GET" warning but it doesn't actually switch.  I guess this is a bug in cURL that comes into play when you combine the -d and -XPOST switches.

    $ curl http://localhost:4567/collection -d"foo=bar" -v -L -XPOST
    
    * About to connect() to localhost port 4567 (#0)
    *   Trying ::1... Connection refused
    *   Trying fe80::1... Connection refused
    *   Trying 127.0.0.1... connected
    * Connected to localhost (127.0.0.1) port 4567 (#0)
    > POST /collection HTTP/1.1
    > User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
    > Host: localhost:4567
    > Accept: */*
    > Content-Length: 7
    > Content-Type: application/x-www-form-urlencoded
    > 
    < HTTP/1.1 302 Moved Temporarily
    < Location: http://localhost:4567/added
    < Content-Type: text/html;charset=utf-8
    < Content-Length: 0
    < Connection: keep-alive
    < Server: thin 1.2.7 codename No Hup
    < 
    * Connection #0 to host localhost left intact
    * Issue another request to this URL: 'http://localhost:4567/added'
    * Violate RFC 2616/10.3.3 and switch from POST to GET
    * Re-using existing connection! (#0) with host localhost
    * Connected to localhost (127.0.0.1) port 4567 (#0)
    > POST /added HTTP/1.1
    > User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3
    > Host: localhost:4567
    > Accept: */*
    > 
    < HTTP/1.1 404 Not Found
    < X-Cascade: pass
    < Content-Type: text/html;charset=utf-8
    < Content-Length: 415
    < Connection: keep-alive
    < Server: thin 1.2.7 codename No Hup
    < 
    * Connection #0 to host localhost left intact
    * Closing connection #0