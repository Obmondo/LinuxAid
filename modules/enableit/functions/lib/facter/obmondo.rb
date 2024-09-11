# This is a custom fact implemented to add the customer ID. Additional parameters can be added as needed.
Facter.add(:obmondo) do
  has_weight 0
  setcode do
    # NOTE: it's not possible to access trusted facts in custom facts, for some
    # reason, which is why we pull it from `puppet_settings`. See also
    # https://ask.puppet.com/question/19949/creating-custom-facts-how-to-access-the-trusted-hash/
    certname = Facter.value('puppet_settings')['agent']['node_name_value'].downcase
    (hostname, customerid) = certname.split('.', 2)

    {
      'customerid'  => customerid,
    }
  end
end
