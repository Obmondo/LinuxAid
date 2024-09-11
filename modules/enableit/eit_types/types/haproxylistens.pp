# Haproxy Listen
#
#role::web::haproxy::listens:
#  graphite_metrics:
#    mode: tcp
#    binds:
#      10.10.10.1:
#        ports:
#          - 2003
#        ssl: false
#        ipaddress: 10.10.10.1
#    servers:
#      - 10.10.10.27:2003
#      - 10.10.10.47:2003
#    extra_options:
#      - balance roundrobin
type Eit_types::HaproxyListens = Hash[
  String,
  Struct[
    {
      mode               => Enum['http','tcp'],
      servers            => Array,
      extra_options      => Variant[Array,Hash],
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
    }
  ]
]
