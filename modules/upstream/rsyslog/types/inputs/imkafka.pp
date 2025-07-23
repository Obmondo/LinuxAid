# Data type for Rsyslog Input module input parameters for Apache Kafka.
type Rsyslog::Inputs::Imkafka = Struct[{
    broker        => Optional[String[1]],
    topic         => String[1],
    confparam     => Optional[Array[String[1]]],
    consumergroup => Optional[String[1]],
    ruleset       => Optional[String[1]],
    parsehostname => Optional[Enum['on', 'off']],
}]
