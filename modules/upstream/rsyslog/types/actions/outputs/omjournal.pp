# Struct data type for the Rsyslog JournalD module's Action options
type Rsyslog::Actions::Outputs::Omjournal = Struct[{
  template => Optional[String[1]],
}]
