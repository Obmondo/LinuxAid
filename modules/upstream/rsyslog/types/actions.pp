# Struct data type alias for Rsyslog Actions
type Rsyslog::Actions = Array[
  Struct[{
      name          => String[1],
      type          => Rsyslog::Modules::Output,
      facility      => Optional[String[1]],
      action_params => Optional[Rsyslog::Actions::Parameters],
      queue_params  => Optional[Rsyslog::Queue::Parameters],
      output_params => Optional[Variant[
          Rsyslog::Actions::Outputs::Omamqp1,
          Rsyslog::Actions::Outputs::Omelasticsearch,
          Rsyslog::Actions::Outputs::Omfile,
          Rsyslog::Actions::Outputs::Omfwd,
          Rsyslog::Actions::Outputs::Omhiredis,
          Rsyslog::Actions::Outputs::Omhttpfs,
          Rsyslog::Actions::Outputs::Omjournal,
          Rsyslog::Actions::Outputs::Omkafka,
          Rsyslog::Actions::Outputs::Omlibdbi,
          Rsyslog::Actions::Outputs::Ommail,
          Rsyslog::Actions::Outputs::Ommongodb,
          Rsyslog::Actions::Outputs::Ommysql,
          Rsyslog::Actions::Outputs::Ompgsql,
          Rsyslog::Actions::Outputs::Ompipe,
          Rsyslog::Actions::Outputs::Omprog,
          Rsyslog::Actions::Outputs::Omrelp,
          Rsyslog::Actions::Outputs::Omsnmp,
          Rsyslog::Actions::Outputs::Omudpspoof,
          Rsyslog::Actions::Outputs::Omusrmsg,
      ]],
  }]
]
