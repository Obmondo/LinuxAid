# @summary This function encrypts a string on the server, and then decrypts it on the agent during catalog application.
function node_encrypt::secret(Variant[String, Sensitive[String]] $data) >> Deferred {
  Deferred('node_decrypt', [node_encrypt($data)])
}
