type Eit_types::Ssh_pubkey_single = Variant[
  Pattern[/((?<type>[^ ]+) )(?<key>AAAA[^ ]+)( (?<comment>.+))/],
  Struct[
    {
    'key' => String,
    'options' => Optional[Array[String]],
    }]]
