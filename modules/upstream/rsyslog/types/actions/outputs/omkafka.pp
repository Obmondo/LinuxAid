# Struct data type for the Rsyslog Kafka module's Action options
type Rsyslog::Actions::Outputs::Omkafka = Struct[{
    broker                => Optional[String[1]],
    topic                 => String[1],
    key                   => Optional[String[1]],
    dynatopic             => Optional[Enum['on', 'off']],
    'dynatopic.cachesize' => Optional[Integer],
    'partitions.auto'     => Optional[Enum['on', 'off']],
    'partitions.number'   => Optional[Integer],
    'partitions.usefixed' => Optional[Integer],
    errorfile             => Optional[String[1]],
    confparam             => Optional[Array[String[1]]],
    topicconfparam        => Optional[Array[String[1]]],
    template              => Optional[String[1]],
    closetimeout          => Optional[Integer],
    resubmitonfailure     => Optional[Enum['on', 'off']],
    keepfailedmessages    => Optional[Enum['on', 'off']],
    failedmsgfile         => Optional[String[1]],
}]
