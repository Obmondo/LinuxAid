# @summary Type Alias for Nginx::UpstreamMemberServer
type Nginx::UpstreamMemberServer = Variant[Stdlib::Host,Pattern[/^unix:\/([^\/\0]+\/*)[^:]*$/]]
