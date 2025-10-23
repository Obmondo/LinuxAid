## Eyaml Hiera

# Encrypting/Decrypting Secrets

* We using [eyaml.sh](../bin/eyaml.sh) which is a wrapper of heira-eyaml to encrypt/decrypt secrets. You can check their [GitHub repo](https://github.com/voxpupuli/hiera-eyaml)

* Make sure that you've the public key present in `var/public_key.pkcs7.pem` in this respository. We already ignoring it in [.gitignore](../.gitignore).

### Examples

1. Encrypt some token

```sh
$ echo "ABCDEFGH-1234-1234-1234-ABCDEFGHIJKL" | ./bin/eyaml.sh
ENC[PKCS7,MIIBmQYJKoZIhvcNAQcDoIIBijCCAYYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEAtT/+mI32f5VO2oDG7WmGAPmc5Ctt0rmtEsMLD2FAURZfI0m0C6w8ScwzdDEsC/C0ZOdQY6iE1sYgV74/i0mwHw4eqeIYJq4TgIJUXK/shAZSxdRGOdi7K5q0RhqPazss8MTA5vTe2/RQ0zv0sKpfFnzX14juSIVC/sKPo6KxjUDKIS/io+rEvFh1/EOr3RzpYNJT4iPD7r84ZNzwUoaTCcFtKFaxl0njfiVZBrbmgh+TJKSMs/gjI+QUXFrw4jn9zhHaHmRg0KhCc1pTudhCWZGv/6gA4JZWscgLKPspT5tMxo1NSMllCT3WD1HdcDygKPuElQQzxJ/zMLCvdlNQLTBcBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBDfc2XAbH8cZC432CAFko6NgDAo4xjSoC67caMck6rJEQP8f6kw90MFq5+ROXOpjLKbZdm6lZ8AFPdR1/3w4T7Pd1A=]
```
