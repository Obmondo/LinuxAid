type Eit_haproxy::Frontend = Struct[{
    domains         => Array[Eit_types::Domain, 1], # Minimum one domain is required, else fail
    force_https     => Boolean,
    servers         => Array[Eit_types::IPPort],
    extra_opts      => Optional[String],
    # client name => token (RFC 6750 syntax); a request without one of these tokens gets a 401
    bearer_tokens   => Optional[Hash[Eit_types::SimpleString, Pattern[/\A[A-Za-z0-9._~+\/-]{16,}=*\z/], 1]],
}]
