# frozen_string_literal: true

require 'rake_factory'
require_relative '../auth/oidc'

module RakeVault
  module Tasks
    class OidcAuth < RakeFactory::Task
      default_name :login
      default_prerequisites(RakeFactory::DynamicValue.new do |t|
        [t.ensure_task_name]
      end)
      default_description(RakeFactory::DynamicValue.new do |_t|
        'Login with oidc using vault'
      end)
      parameter :role
      parameter :address
      parameter :ensure_task_name, default: :'vault:ensure'
      parameter :no_print, default: false

      action do |task|
        RakeVault::Auth::Oidc.login(task.address, task.role, task.no_print)
      end
    end
  end
end
