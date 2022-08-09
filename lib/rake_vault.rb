# frozen_string_literal: true

require 'rake_vault/tasks'
require 'rake_vault/task_sets'
require 'rake_vault/version'

module RakeVault
  def self.define_installation_tasks(opts = {})
    RakeVault::TaskSets::Vault.define(opts).delegate
  end

  def self.define_oidc_auth_task(opts = {}, &block)
    RakeVault::Tasks::OidcAuth.define(opts, &block)
  end
end
