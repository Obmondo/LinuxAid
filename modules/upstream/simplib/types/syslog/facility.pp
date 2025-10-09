# Syslog facilities
type Simplib::Syslog::Facility = Variant[
  Simplib::Syslog::LowerFacility,
  Simplib::Syslog::UpperFacility,
  Simplib::Syslog::CFacility
]
