# Common options type
type Drbd::Common_suboptions = Struct[
  {
    handlers => Optional[Array[String[1]]],
    startup  => Optional[Array[String[1]]],
    options  => Optional[Array[String[1]]],
    disk     => Optional[Array[String[1]]],
    net      => Optional[Array[String[1]]],
  }
]
