# Syslog priorities
type Simplib::Syslog::Priority = Variant[
  Simplib::Syslog::LowerPriority,
  Simplib::Syslog::UpperPriority,
  Simplib::Syslog::CPriority
]
