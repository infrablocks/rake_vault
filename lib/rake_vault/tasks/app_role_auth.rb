# frozen_string_literal: true

require 'rake_factory'
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
        role_id = task.role_id ? "role_id=#{task.role_id}" : nil
        secret_id = task.secret_id ? "secret_id=#{task.secret_id}" : nil

        stdout_io = StringIO.new

        RubyVault.configure do |config|
          config.stdout = stdout_io
        end

        RubyVault.write(
          address: task.address,
          path: task.path,
          data: [role_id, secret_id].compact,
          format: 'json'
        )
        RubyVault.configure do |config|
          config.stdout = $stdout
        end
        RakeVault::TokenFile.write(stdout_io.string)
      end
    end
  end
end
