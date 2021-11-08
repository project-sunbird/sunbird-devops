vcl 4.0;
import std;

backend default {
  .host = "uci-service.{{namespace}}.svc.cluster.local:9999";
}

sub vcl_recv {
    if (req.method == "PRI") {
	/* We do not support SPDY or HTTP/2.0 */
	return (synth(405));
    }
    if (req.method != "GET" &&
      req.method != "HEAD" &&
      req.method != "PUT" &&
      req.method != "POST" &&
      req.method != "TRACE" &&
      req.method != "OPTIONS" &&
      req.method != "DELETE") {
        /* Non-RFC2616 or CONNECT which is weird. */
        return (pipe);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        /* We only deal with GET and HEAD by default */
        return (pass);
    }
    return (hash);
}

sub vcl_backend_response {
    return (deliver);
}

sub vcl_hit {
	set req.http.x-cache = "hit";
}

sub vcl_miss {
	set req.http.x-cache = "miss";
}

sub vcl_pass {
	set req.http.x-cache = "pass";
}

sub vcl_deliver {
	if (obj.uncacheable) {
		set req.http.x-cache = req.http.x-cache + " uncacheable" ;
	} else {
		set req.http.x-cache = req.http.x-cache + " cached" ;
	}
	set resp.http.x-cache = req.http.x-cache;
}
