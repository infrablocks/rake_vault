# frozen_string_literal: true

require 'rake_factory'
require 'ruby_vault'

module RakeVault
  module Tasks
    class OidcAuth < RakeFactory::Task
      default_name :login
      default_prerequisites(RakeFactory::DynamicValue.new do |t|
        [t.ensure_task_name]
      end)
      parameter :role
      parameter :address
      parameter :ensure_task_name, default: :'vault:ensure'

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
