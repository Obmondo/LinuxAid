# Syslog severities
type Simplib::Syslog::Severity = Variant[
  Simplib::Syslog::LowerSeverity,
  Simplib::Syslog::UpperSeverity,
  Simplib::Syslog::CSeverity
]
