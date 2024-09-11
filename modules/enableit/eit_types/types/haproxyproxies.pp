# Haproxy Proxies
# Sample
#
#role::web::haproxy::encryption_ciphers: strict
#role::web::haproxy::configure:
# auto:
#   proxies:
#     web:
#       mode: http
#       letsencrypt: false
#       binds:
#         10.192.1.30_http:
#           ports:
#             - 80
#           ssl: false
#           ipaddress: 10.192.1.30
#       sites:
#         phpfpm:
#           domains:
#             - 'rema_php.com'
#           servers:
#             - '10.192.1.40:80'
#             - '10.192.1.41:80'
#             - '10.192.1.42:80'
#             - '10.192.1.43:80'
type Eit_types::HaproxyProxies = Hash[
  String,
  Struct[
    {
      letsencrypt        => Boolean,
      mode               => Enum['http','tcp'],
      binds              => Hash[
        String,
        Struct[
          {
            ports     => Variant[Array[Stdlib::Port],Stdlib::Port],
            ipaddress => Eit_types::IP,
            ssl       => Boolean,
            options   => Optional[Variant[String, Array[String]]],
          }
        ]
      ],
      sites             => Hash[
        String,
        Struct[
          {
            servers             => Array[String, 1],
            domains             => Optional[Array[String]],
            use_backend_options => Optional[String],
            ssl_fc              => Optional[String],
            force_https         => Optional[Boolean],
            backend_options     => Optional[Struct[
              {
                server_options => Optional[String],
                extra_options  => Optional[Array],
              }
            ]],
            frontend_options    => Optional[String],
            header              => Optional[String],
            paths               => Optional[Variant[Array[Stdlib::Absolutepath, 1], Array]],
            urls                => Optional[Variant[Array[Stdlib::Absolutepath, 1]]],
            default_backend     => Optional[Boolean],
          }
        ]
      ],
      extra_options      => Optional[Struct[
        {
          option         => Optional[Array],
          acl            => Optional[Array],
          http           => Optional[Array],
          redirect_rules => Optional[Array],
          no             => Optional[Array],
          timeout        => Optional[Array],
          log            => Optional[Array],
          errorfile      => Optional[Array],
        }
      ]],
    }
  ]
]
