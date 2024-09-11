Puppet::Functions.create_function(:random_string) do
  # @param length Length of string to be generated.
  #
  # @return [String] Random string.
  dispatch :random_string do
    optional_param 'Integer[1]', :length
  end

  def random_string(length=16)
    require 'digest/sha2'

    charset ||= '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

    random_generator = Random.new()

    Array.new(length) { charset[random_generator.rand(charset.size)] }.join
  end
end
