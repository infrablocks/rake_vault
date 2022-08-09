# frozen_string_literal: true

require 'rake_factory'

module RakeVault
  module Tasks
    class OidcAuth < RakeFactory::Task
      default_name :login
      parameter :role
      parameter :address

      action do |task|
        auth = task.role ? ["role=#{task.role}"] : []

        RubyVault.login(
          method: 'oidc',
          auth: auth,
          address: task.address
        )
      end
    end
  end
end
