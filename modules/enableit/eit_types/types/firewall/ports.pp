type Eit_types::Firewall::Ports = Array[
  Variant[
    Stdlib::Port,
    # Valid examples, one per line. Note that these are valid according to the
    # regex, not necessarily valid according to iptables or firewall_multi.
    #
    # ! 100-200
    # 123-127
    # 000-000
    # 99999999-1
    Pattern[/^(! )?[0-9]+(-[0-9]+)$/]
  ]
]
