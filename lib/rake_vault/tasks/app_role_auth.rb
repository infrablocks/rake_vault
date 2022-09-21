# frozen_string_literal: true

require 'rake_factory'
require_relative '../auth/approle'
require_relative '../token_file'

module RakeVault
  module Tasks
    class AppRoleAuth < RakeFactory::Task
      default_name :login
      default_prerequisites(RakeFactory::DynamicValue.new do |t|
        [t.ensure_task_name]
      end)
      default_description(RakeFactory::DynamicValue.new do |_t|
        'Login with app role using vault'
      end)
      parameter :address
      parameter :ensure_task_name, default: :'vault:ensure'
      parameter :path, default: 'auth/approle/login'
      parameter :role_id
      parameter :secret_id

      action do |task|
        RakeVault::Auth::Approle.login(
          task.address,
          task.path,
          task.role_id,
          task.secret_id
        )
      end
    end
  end
end
