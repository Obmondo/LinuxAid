function node_encrypt::secret(Variant[String, Sensitive[String]] $data) >> Deferred {
  Deferred("node_decrypt", [node_encrypt($data)])
}
