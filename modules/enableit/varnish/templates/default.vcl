# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
# 
# Default backend definition.  Set this to point to your content
# server.
# 

backend webtv_backendvip {
  .host = "10.233.2.14";
  .port = "80";
  .first_byte_timeout = 300s;
}
backend webtvtest_backendvip {
  .host = "10.233.2.15";
  .port = "80";
  .first_byte_timeout = 300s;
}

director director_webtv round-robin {
	{
		.backend = webtv_backendvip;
	}
}

director director_webtvtest round-robin {
	{
		.backend = webtvtest_backendvip;
	}
}

#director director_stage_yousee_dk round-robin {
#	{
# 	 .backend = portal_server8;
#	}
#}
#
#director director_test_yousee_dk round-robin {
#	{
#  	.backend = portal_server9;
#	}
#}

acl purgers {
    "127.0.0.1"; 
}

sub vcl_recv {
        if (req.request == "PURGE") {
                if (!client.ip ~ purgers) {
                        error 405 "Method not allowed";
                }
                return (lookup);
        }

	#don't allow clients to force flush varnish cache
	unset req.http.Cache-Control;

	#remove get params so we cache the request 
	if (req.url ~ "\/feeds\/iphone\/tvguide\/programs.json.*") {
		set req.url = regsub(req.url, "\?.*", "");
	}

#
# Indsat af jesar for at sikre at web sider fra server der er nede ikke bliver $
#

if (req.backend.healthy) {
    set req.grace = 30s;
  } else {
    set req.grace = 10s;
  }


#
# indsat af jesar for at redele webtv stage (stage.yousee.tv) trafik til portal server 8
#


if (req.http.host ~ "(pp|beta).yousee.tv$")
{
	set req.backend = director_webtvtest;
}
else
{
	set req.backend = director_webtv;
}

#else
#{
#if (req.http.host ~ "stager.yousee.tv$")
#{
#
#  set req.backend = director_stage_yousee_dk;
#} else
#if (req.http.host ~ "test.yousee.tv$")
#{
# set req.backend = director_test_yousee_dk;
#}
#}


# not necessary for varnish 3
#if (req.http.Accept-Encoding) {
#   if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
#      # No point in compressing these
#      remove req.http.Accept-Encoding;
#   } else if (req.http.Accept-Encoding ~ "gzip") {
#     set req.http.Accept-Encoding = "gzip";
#   } else if (req.http.Accept-Encoding ~ "deflate") {
#     set req.http.Accept-Encoding = "deflate";
#   } else {
#     # unknown algorithm
#     remove req.http.Accept-Encoding;
#   }
#}

#			not setting that - since ACE takes care of it
#     if (req.restarts == 0) {
#        if (req.http.x-forwarded-for) {
#            set req.http.X-Forwarded-For =
#                req.http.X-Forwarded-For + ", " + client.ip;
#        } else {
#            set req.http.X-Forwarded-For = client.ip;
#        }
#     }
     if (req.request != "GET" &&
       req.request != "HEAD" &&
       req.request != "PUT" &&
       req.request != "POST" &&
       req.request != "TRACE" &&
       req.request != "OPTIONS" &&
       req.request != "DELETE") {
         /* Non-RFC2616 or CONNECT which is weird. */
         return (pipe);
     }
     if (req.request != "GET" && req.request != "HEAD") {
         /* We only deal with GET and HEAD by default */
         return (pass);
     }
     if (req.http.Authorization) {
         /* Not cacheable by default */
         return (pass);
     }

     return (lookup);
}
sub vcl_hit {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged";
        }
}
sub vcl_miss {
        if (req.request == "PURGE") {
                purge;
                error 404 "Not in cache";
        }
}
sub vcl_pass {
        if (req.request == "PURGE") {
                error 502 "PURGE on a passed object";
        }
}

sub vcl_fetch {

        set beresp.grace = 30s;
    #    if (!beresp.cacheable) {
    #     return (pass);
    # }
#     if (beresp.http.Set-Cookie) {
#         return (hit_for_pass);
#     }

    /* ignores no-cache documents */
    if(beresp.http.Pragma ~ "no-cache" ||
       beresp.http.Cache-Control ~ "no-cache" ||
       beresp.http.Cache-Control ~ "private"){

       return(hit_for_pass);

    }
        return (deliver);
}

sub vcl_deliver {
        if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT";
        } else {
                set resp.http.X-Cache = "MISS";
        }
     return (deliver);
}

#
#
# 
 sub vcl_error {
     set obj.http.Content-Type = "text/html; charset=utf-8";
     set obj.http.Retry-After = "5";
     synthetic {"
 <?xml version="1.0" encoding="utf-8"?>
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html>
   <head>
     <title>"} + obj.status + " " + obj.response + {"</title>
     <meta HTTP-EQUIV="REFRESH" content="0; url=http://cloud.yousee.tv/misc/service/index.html">
  </head>
   <body>
     <h1>Error "} + obj.status + " " + obj.response + {"</h1>
     <p>"} + obj.response + {"</p>
     <h3>Guru Meditation:</h3>
     <p>XID: "} + req.xid + {"</p>
     <hr>
     <p>Varnish cache server</p>
   </body>
 </html>
 "};
     return (deliver);
 }
# 
# sub vcl_init {
#       return (ok);
# }
# 
# sub vcl_fini {
#       return (ok);
# }
#
# sat ind af jesper
#
#


sub vcl_deliver {
        if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT : indholdet er fundet i systemet";
        } else {
                set resp.http.X-Cache = "MISS : indholdet er ikke fundet i systemet og bliver hentet i web systemet";
        }
}


sub vcl_fetch {

    # Varnish determined the object was not cacheable
    if (beresp.ttl <= 0s) {
        set beresp.http.X-Cacheable = "NO:Not Cacheable";

    # You don't wish to cache content for logged in users
    } elsif (req.http.Cookie ~ "(UserID|_session)") {
        set beresp.http.X-Cacheable = "NO:Got Session";
        return(hit_for_pass);

    # You are respecting the Cache-Control=private header from the backend
    } elsif (beresp.http.Cache-Control ~ "private") {
        set beresp.http.X-Cacheable = "NO:Cache-Control=private";
        return(hit_for_pass);

    # Varnish determined the object was cacheable
    } else {
        set beresp.http.X-Cacheable = "YES";
    }

    # ....

    return(deliver);
}

