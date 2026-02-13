# @summary Splits a certname into node_name and customer_id parts.
#
# This function matches the input string against a strict regex pattern.
# It uses an early-return pattern: if the match succeeds, it returns immediately.
# If execution reaches the end of the function, it implies the match failed.
#
# @example 1. Standard valid usage
#   $result = functions::split_certname('web01.client55')
#   # Output ($result):
#   # {
#   #   'node_name'   => 'web01',
#   #   'customer_id' => 'client55'
#   # }
#
# @example 2. Using trusted facts (common scenario)
#   # Assuming $trusted['certname'] is 'db-02.acme-corp'
#   $data = functions::split_certname($trusted['certname'])
#   # Output ($data):
#   # {
#   #   'node_name'   => 'db-02',
#   #   'customer_id' => 'acme-corp'
#   # }
#
# @example 3. Invalid input triggers compilation error
#   functions::split_certname('invalid_string_without_dot')
#   # Output:
#   # Error: Evaluation Error: Error while evaluating a Function Call, invalid certname
#
# @param certname
#   The certificate name string to split.
#   Must match the pattern `^[a-z0-9-]+\.[a-z0-9-]+$`.
#
# @return [Hash[String, String]]
#   A hash containing the keys 'node_name' and 'customer_id'.
#
function functions::split_certname(String $certname) {
  # The if statement binds the variables $node_name and $customer_id
  $certname_match = $certname.match(/^(?<node_name>[a-z0-9-]+)\.(?<customer_id>[a-z0-9-]+$)/)

  unless $certname_match {
    fail('certname matching failed during split.')
  }

  Hash([
      'node_name'  ,$certname_match[1],
      'customer_id',$certname_match[2],
  ])
}
