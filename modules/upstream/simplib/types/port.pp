# A valid port Type
type Simplib::Port = Variant[
  Simplib::Port::Random,
  Simplib::Port::System,
  Simplib::Port::User,
  Simplib::Port::Dynamic
]
