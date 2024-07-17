# frozen_string_literal: true

require 'ruby_vault'

module RakeVault
  module Auth
    module Approle
      def self.login(address, path, role_id, secret_id)
        role_id = role_id ? "role_id=#{role_id}" : nil
        secret_id = secret_id ? "secret_id=#{secret_id}" : nil

        stdout_io = StringIO.new

        configure_stdout(stdout_io)
        write(address, path, role_id, secret_id)
        reset_stdout
        RakeVault::TokenFile.write(stdout_io.string)
      end

      def self.write(address, path, role_id, secret_id)
        RubyVault.write(
          address:,
          path:,
          data: [role_id, secret_id].compact,
          format: 'json'
        )
      end

      def self.configure_stdout(stdout_io)
        RubyVault.configure do |config|
          config.stdout = stdout_io
        end
      end

      def self.reset_stdout
        RubyVault.configure do |config|
          config.stdout = $stdout
        end
      end
    end
  end
end
