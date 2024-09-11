# Convert firewall_multi type data to firewall type data.
Puppet::Functions.create_function(:firewall_multi) do
  # @summary Take a name and a hash and return a modified hash suitable
  #   for input to create_resources().
  #
  # @note Given this input:
  #
  #   ```ruby
  #   [
  #     {
  #       "00100 accept inbound ssh" => {
  #         "jump" => "accept",
  #         "source" => ["1.1.1.1/24", "2.2.2.2/24"],
  #         "dport"  => 22,
  #       },
  #     }
  #   ]
  #   ```
  #
  #   Return this:
  #
  #   ```ruby
  #   {
  #     "00100 accept inbound ssh from 1.1.1.1/24" => {
  #       "jump" => "accept",
  #       "source" => "1.1.1.1/24",
  #       "dport"  => 22,
  #     },
  #     "00100 accept inbound ssh from 2.2.2.2/24" => {
  #       "jump" => "accept",
  #       "source" => "2.2.2.2/24",
  #       "dport"  => 22,
  #     },
  #   }
  #   ```
  #
  # @param hash The original resource params data.
  # @return Modified Hash for firewall types to be passed to create_resources().
  #
  dispatch :firewall_multi do
    param "Hash", :hash
  end

  def explode(hash, param, string)
    exploded = {}

    hash.each do |title, params|
      if params.key?(param) &&
         params[param].is_a?(Array)

        params[param].each do |val|
          new = [title, string, val].join(" ")
          exploded[new] = params.dup
          exploded[new][param] = val
        end

        next
      end
      exploded[title] = params.clone
    end

    exploded
  end

  def firewall_multi(hash)
    hash = explode(hash, "source", "from")
    hash = explode(hash, "destination", "to")
    hash = explode(hash, "proto", "proto")
    hash = explode(hash, "icmp", "icmp type")
    hash = explode(hash, "protocol", "using protocol")
    hash
  end
end
