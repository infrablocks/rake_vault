# frozen_string_literal: true

require 'spec_helper'

describe RakeVault::Tasks::Login do
  include_context 'rake'

  before do
    namespace :vault do
      task :ensure
    end
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :auth }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a login task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('auth:login'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['auth:login'].full_comment)
      .to(eq('Login with approle or oidc using vault'))
  end

  it 'allows multiple login tasks to be declared' do
    define_task(namespace: :auth1)
    define_task(namespace: :auth2)

    expect(Rake.application).to(have_task_defined('auth1:login'))
    expect(Rake.application).to(have_task_defined('auth2:login'))
  end

  it 'depends on the vault:ensure task by default' do
    define_task

    expect(Rake::Task['auth:login'].prerequisite_tasks)
      .to(include(Rake::Task['vault:ensure']))
  end

  it 'logs in with oidc by default when not logged in' do
    define_task
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Oidc)
      .to(have_received(:login).with(anything, anything, anything))
  end

  it 'logs in with oidc by default when not logged in with server error' do
    define_task
    stub_logins
    stub_token_lookup_server_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Oidc)
      .to(have_received(:login).with(anything, anything, anything))
  end

  it 'uses provided address when logging in with oidc' do
    address = 'https://some-vault.com'
    define_task({ address: address })
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Oidc)
      .to(have_received(:login).with(address, anything, anything))
  end

  it 'uses provided role when logging in with oidc' do
    role = 'some-role'
    define_task({ role: role })
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Oidc)
      .to(have_received(:login).with(anything, role, anything))
  end

  it 'sets no_print to true when logging in with oidc' do
    define_task
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Oidc)
      .to(have_received(:login).with(anything, anything, true))
  end

  it 'logs in with approle when approle credentials provided via env' do
    approle_role_id = 'some-role'
    approle_secret_id = 'some-secret'
    ENV['VAULT_APPROLE_ROLE_ID'] = approle_role_id
    ENV['VAULT_APPROLE_SECRET_ID'] = approle_secret_id
    define_task
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Approle)
      .to(have_received(:login).with(anything, anything, approle_role_id,
                                     approle_secret_id))
  end

  it 'uses provided address when logging in with approle' do
    address = 'https://some-vault.com'
    ENV['VAULT_APPROLE_ROLE_ID'] = 'some-role'
    ENV['VAULT_APPROLE_SECRET_ID'] = 'some-secret'
    define_task({ address: address })
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Approle)
      .to(have_received(:login).with(address, anything, anything, anything))
  end

  it 'uses auth/approle/login as path when logging in with approle' do
    ENV['VAULT_APPROLE_ROLE_ID'] = 'some-role'
    ENV['VAULT_APPROLE_SECRET_ID'] = 'some-secret'
    define_task
    stub_logins
    stub_token_lookup_client_error

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Approle)
      .to(have_received(:login).with(anything, 'auth/approle/login', anything,
                                     anything))
  end

  it 'does not log in when token self lookup succeeds' do
    ENV['VAULT_APPROLE_ROLE_ID'] = 'some-role'
    ENV['VAULT_APPROLE_SECRET_ID'] = 'some-secret'
    define_task
    stub_logins
    stub_token_lookup_success

    Rake::Task['auth:login'].invoke

    expect(RakeVault::Auth::Approle).not_to(have_received(:login))
    expect(RakeVault::Auth::Oidc).not_to(have_received(:login))
  end

  def stub_logins
    allow(RakeVault::Auth::Oidc).to(receive(:login))
    allow(RakeVault::Auth::Approle).to(receive(:login))
  end

  def stub_token_lookup_client_error
    stub_token_lookup_error(Vault::HTTPClientError.new('', FakeResponse.new))
  end

  def stub_token_lookup_server_error
    stub_token_lookup_error(Vault::HTTPServerError.new('', FakeResponse.new))
  end

  def stub_token_lookup_error(error)
    client = instance_double(Vault::Client, 'vault client')
    auth_token = instance_double(Vault::AuthToken, 'vault auth token')
    allow(Vault::Client).to(receive(:new)).and_return(client)
    allow(client).to(receive(:auth_token)).and_return(auth_token)
    allow(auth_token).to(receive(:lookup_self)).and_raise(error)
  end

  def stub_token_lookup_success
    client = instance_double(Vault::Client, 'vault client')
    auth_token = instance_double(Vault::AuthToken, 'vault auth token')
    allow(Vault::Client).to(receive(:new)).and_return(client)
    allow(client).to(receive(:auth_token)).and_return(auth_token)
    allow(auth_token).to(receive(:lookup_self)).and_return(nil)
  end
end

class FakeResponse
  def code
    500
  end
end
