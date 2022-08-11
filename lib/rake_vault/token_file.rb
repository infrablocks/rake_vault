# frozen_string_literal: true

module RakeVault
  module TokenFile
    def self.write(json_string)
      json = JSON.parse(json_string)
      token = json['auth']['client_token']
      RakeVault::TokenFile.write_token_to_file(token)
    end

    def self.write_token_to_file(token)
      file = File.open(File.expand_path('~/.vault-token'), 'w')
      file.write(token)
      file.close
    end
  end
end
