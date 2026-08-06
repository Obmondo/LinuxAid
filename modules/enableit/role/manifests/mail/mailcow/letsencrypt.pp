# @summary Let's Encrypt settings for mailcow, used when `letsencrypt` is enabled
#
# @param acme_contact The contact email for Let's Encrypt ACME. Defaults to undef, in which
#   case `common::system::certs::letsencrypt::email` is used.
#
# @groups letsencrypt acme_contact
#
class role::mail::mailcow::letsencrypt (
  Optional[Eit_types::Email] $acme_contact = undef,
) {
}
