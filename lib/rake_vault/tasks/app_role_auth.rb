# frozen_string_literal: true

require 'rake_factory'

module RakeVault
  module Tasks
    class AppRoleAuth < RakeFactory::Task
      default_name :app_role_auth
      action do |_t|
        puts 'done'
      end
    end
  end
end
