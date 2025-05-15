require_relative "api"

Puppet::Functions.create_function(:obmondo_customers) do
  def obmondo_customers
    obmondo_api("/customers").select { |customer|
      customer["id"] != "4testing"
    }
  end
end
