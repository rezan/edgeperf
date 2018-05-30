vcl 4.0;

import std;
import edgestash;
import kvstore;
import xbody;

backend default
{
  .host = "localhost";
  .port = "8008";
}

sub vcl_init
{
    // JSON cache
    new json_cache = kvstore.init();
}

sub vcl_recv
{
    // Random url and id (0-99)
    set req.url = "/edgeperf/data/" + std.integer(std.random(0, 100), 0) + ".txt";
    set req.http.X-id = std.integer(std.random(0, 100), 0);

    unset req.http.X-capture;

    // We have no JSON for the id
    if (!json_cache.get(req.http.X-id)) {
        set req.http.X-capture = "true";
        return (pass);
    }

    return (hash);
}

sub vcl_backend_response
{
    set beresp.ttl = 3s;

    xbody.capture("0", "0: (\S+)", "\1");
    xbody.capture("1", "1: (\S+)", "\1");
    xbody.capture("2", "2: (\S+)", "\1");
    xbody.capture("3", "3: (\S+)", "\1");
    xbody.capture("4", "4: (\S+)", "\1");
    xbody.capture("5", "5: (\S+)", "\1");
    xbody.capture("6", "6: (\S+)", "\1");
    xbody.capture("7", "7: (\S+)", "\1");
    xbody.capture("8", "8: (\S+)", "\1");
    xbody.capture("9", "9: (\S+)", "\1");

    xbody.regsub("([0-9]+): \S+", "\1: {{\1}}");

    edgestash.parse_response();
}

sub vcl_deliver
{
    // Cache the captured JSON
    if (req.http.X-capture) {
        json_cache.set(req.http.X-id, xbody.get_all(), 3s);
        json_cache.delete("count" + req.http.X-id);
    }

    edgestash.add_json(json_cache.get(req.http.X-id));
    edgestash.execute();

    set resp.http.X-id = req.http.X-id;
    set resp.http.X-url = req.url;
    set resp.http.X-hits = obj.hits;
    set resp.http.X-json-hits = json_cache.counter("count" + req.http.X-id, 1);
}
