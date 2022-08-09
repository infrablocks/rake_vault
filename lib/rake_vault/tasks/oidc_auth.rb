# frozen_string_literal: true

require 'rake_factory'

module RakeVault
  module Tasks
    class OidcAuth < RakeFactory::Task
      default_name :login
      parameter :role

      action do |task|
        RubyVault.login(
          method: 'oidc',
          role: task.role
        )
      end
    end
  end
end
