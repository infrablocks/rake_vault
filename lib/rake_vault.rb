# frozen_string_literal: true

require 'rake_vault/tasks'
require 'rake_vault/task_sets'
require 'rake_vault/version'
require 'rake_vault/token_file'

module RakeVault
  def self.define_installation_tasks(opts = {})
    command_task_set = define_command_installation_tasks(opts)

    configure_ruby_vault(command_task_set.binary)

    command_task_set.delegate
  end

  def self.define_oidc_auth_task(opts = {}, &block)
    RakeVault::Tasks::OidcAuth.define(opts, &block)
  end

  def self.define_app_role_auth_task(opts = {}, &block)
    RakeVault::Tasks::AppRoleAuth.define(opts, &block)
  end

  def self.define_login_task(opts = {}, &block)
    RakeVault::Tasks::Login.define(opts, &block)
  end

  class << self
    private

    def define_command_installation_tasks(opts = {})
      RakeVault::TaskSets::Vault.define(opts)
    end

    def configure_ruby_vault(binary)
      RubyVault.configure { |c| c.binary = binary }
    end
  end
end
