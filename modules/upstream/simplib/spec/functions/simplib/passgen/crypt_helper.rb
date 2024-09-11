require 'base64'

module CryptHelper
  def parse_modular_crypt(input)
    retval = nil
    support_params = {
      'bcrypt' => {},
      'scrypt' => {},
      'argon2' => {},
    }
    algorithm_lookup = {
      '1' => 'md5',
      '2' => 'bcrypt',
      '3' => 'lmhash',
      '5' => 'sha256',
      '6' => 'sha512',
      'scrypt' => 'scrypt',
      'argon2' => 'argon2',
    }
    begin
      grab_params = false
      grab_salt = false
      grab_hash = false
      hash = {}
      split_input = input.split("$");
      index = 0;
      if (split_input.size > 2)
        split_input.each do |token|
          if (index == 1)
            hash['algorithm_code'] = token;
            if (algorithm_lookup.key?(token))
              hash['algorithm'] = algorithm_lookup[token];
              if (support_params.key?(hash['algorithm']))
                grab_params = true
              end
              grab_salt = true
              grab_hash = true
            end
          else
            if grab_params == true
              hash['params'] = token
              grab_params = false
            elsif grab_salt == true
              hash['salt'] = token
              grab_salt = false
            elsif grab_hash == true
              padding = token.length % 4
              hash['hash_orig'] = token
              hash['hash_base64'] = token.gsub(/\./, '+').rjust(padding + token.length, '=')
              hash['hash_decoded'] = Base64.decode64(hash['hash_base64']).bytes.to_a
              hash['hash_bitlength'] = hash['hash_decoded'].size * 8;
              grab_hash = false
            end
          end
          index += 1;
        end
        retval = hash
      end
    rescue Exception => e
      puts e
      retval = nil
    end
    return retval
  end
end
