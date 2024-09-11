# Rsyslog Remote Server
# 'syslog01.com:514': 'tcp'
# @@syslog01.com:514
# 'syslog02.com:514': 'udp'
# @syslog02.com:514

type Eit_types::Rsyslog::Remote_Ip = Hash[
  Stdlib::Host,
  Struct[{
    port  => Stdlib::Port,
    proto => Eit_types::Proto
  }]
]
