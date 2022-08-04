# frozen_string_literal: true

require 'rake_factory'

module RakeVault
  module Tasks
    class Login < RakeFactory::Task
      default_name :login
      action do |_t|
        puts 'done'
      end
    end
  end
end
