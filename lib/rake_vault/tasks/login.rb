# frozen_string_literal: true

require 'rake_factory'
require 'vault'
require_relative '../auth/approle'
require_relative '../auth/oidc'

module RakeVault
  module Tasks
    class Login < RakeFactory::Task
      default_name :login
      default_prerequisites(RakeFactory::DynamicValue.new do |t|
        [t.ensure_task_name]
      end)
      default_description(RakeFactory::DynamicValue.new do |_t|
        'Login with approle or oidc using vault'
      end)
      parameter :address
      parameter :role
      parameter :ensure_task_name, default: :'vault:ensure'

      action do |task|
        puts 'Logging into vault...'
        if valid_token?(task.address)
          puts 'Valid token found.'
        else
          puts 'No valid token found. Attempting to login...'
          app_role_role_id = ENV.fetch('VAULT_APPROLE_ROLE_ID', nil)
          app_role_secret_id = ENV.fetch('VAULT_APPROLE_SECRET_ID', nil)
          if app_role_role_id && app_role_secret_id
            puts 'Approle credentials found. Logging in with approle...'
            RakeVault::Auth::Approle.login(
              task.address,
              'auth/approle/login',
              app_role_role_id,
              app_role_secret_id
            )
          else
            RakeVault::Auth::Oidc.login(task.address, task.role, true)
          end
        end
      end

      def valid_token?(address)
        puts 'Checking for valid token...'
        vault_client = Vault::Client.new(address:)
        vault_client.auth_token.lookup_self
      rescue Vault::HTTPClientError, Vault::HTTPServerError
        false
      else
        true
      end
    end
  end
end
