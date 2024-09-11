# frozen_string_literal: true
#
# We're getting into the intersection in the Venn diagram between awesome and
# terrible code here. ...but I guess that's the cost, when you don't have a lisp
# available... :)
#
# Example fact data:
#
#   {
#     "corp.example.org": {
#       "online": true,
#       "active_servers": {
#         "ad global catalog": "dkcphdchear01.corp.example.org",
#         "ad domain controller": "dkcphdchear01.corp.example.org"
#       },
#       "global_catalog_servers": [
#         "dkcphdchear01.corp.example.org",
#         "dkcphdchear02.corp.example.org"
#       ],
#       "domain_controller_servers": [
#         "dkcphdchear01.corp.example.org",
#         "dkcphdchear02.corp.example.org"
#       ]
#     },
#     "example.org": {
#       "online": true,
#       "active_servers": {
#         "ad domain controller": "dkcphdccorp02.example.org",
#         "ad global catalog": "dkcphdchear01.corp.example.org"
#       },
#       "global_catalog_servers": [
#         "dkcphdccorp02.example.org",
#         "dkcphdccorp01.example.org",
#         "dkcphdccorp02.example.org",
#         "jptokdccorp01.example.org",
#         "cnxmndccorp02.example.org",
#         "jptokdccorp01.example.org",
#         "usglvdccorp01.example.org",
#         "cnxmndccorp01.example.org",
#         "dkaardccorp01.example.org",
#         "cnxmndccorp02.example.org",
#         "usglvdccorp01.example.org",
#         "myjhbdccorp01.example.org",
#         "usblmdccorp01.example.org",
#         "myjhbdccorp01.example.org"
#       ],
#       "domain_controller_servers": [
#         "dkcphdchear01.corp.example.org",
#         "dkcphdchear02.corp.example.org"
#       ]
#     }
#   }

def domain_status(raw)
  chunks = raw.split("\n\n")

  return nil if chunks.count != 4

  result = {}
  result['online'] = !!(chunks[0].match(/Online$/))

  result['active_servers'] = chunks[1]
                             .split("\n")
                             .drop(1)
                             .map { |x| x.split(': ') }
                             .flatten
                             .map(&:downcase)
                             .each_slice(2)
                             .to_h

  result['global_catalog_servers'] = chunks[2]
                                     .split("\n- ")
                                     .drop(1)
                                     .map(&:downcase)

  result['domain_controller_servers'] = chunks[3]
                                        .split("\n- ")
                                        .drop(1)
                                        .map(&:downcase)

  result
end

Facter.add(:sssd) do
  confine kernel: :linux
  confine { Facter::Core::Execution.which('sssctl') }

  setcode do
    # `sssctl domain-list` example output:
    #
    #
    # # sssctl domain-list
    # corp.example.org
    # example.org
    #
    # # sssctl domain-status corp.example.org
    #
    # Online status: Online
    #
    # Active servers:
    # AD Global Catalog: SPBADC01.corp.example.org
    # AD Domain Controller: SPBADC01.corp.example.org
    #
    # Discovered AD Global Catalog servers:
    # - SPBADC01.corp.example.org
    # - SPBADC02.corp.example.org
    #
    # Discovered AD Domain Controller servers:
    # - SPBADC01.corp.example.org
    # - SPBADC02.corp.example.org
    domains = Facter::Util::Resolution
              .exec('sssctl domain-list')
              .strip
              .split

    domains_details = domains.map { |domain|
      status = Facter::Util::Resolution
               .exec("sssctl domain-status #{domain}")
               .strip
      { domain => domain_status(status) }
    }.reduce(&:merge)

    domains_details
  end
end
