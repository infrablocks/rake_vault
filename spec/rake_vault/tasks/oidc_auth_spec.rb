# frozen_string_literal: true

require 'ruby_vault'
require 'spec_helper'

describe RakeVault::Tasks::OidcAuth do
  include_context 'rake'

  before do
    namespace :vault do
      task :ensure
    end
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :oidc }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a login task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('oidc:login'))
  end

  it 'allows multiple login tasks to be declared' do
    define_task(namespace: :oidc1)
    define_task(namespace: :oidc2)

    expect(Rake.application).to(have_task_defined('oidc1:login'))
    expect(Rake.application).to(have_task_defined('oidc2:login'))
  end

  it 'depends on the vault:ensure task by default' do
    define_task

    expect(Rake::Task['oidc:login'].prerequisite_tasks)
      .to(include(Rake::Task['vault:ensure']))
  end

  it 'passes method oidc to login' do
    define_task
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(method: 'oidc')))
  end

  it 'does not pass role to login within auth parameter when role not passed' do
    define_task
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(auth: excluding(a_string_including('role=')))))
  end

  it 'does not pass role to login within auth parameter when role is nil' do
    define_task do |t|
      t.role = nil
    end
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(auth: excluding(a_string_including('role=')))))
  end

  it 'passes the provided role to login within auth parameter when present' do
    define_task do |t|
      t.role = 'some-role'
    end
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(auth: including('role=some-role'))))
  end

  it 'passes the provided value for the address parameter to login "\
  "when present' do
    address = 'https://vault.example.com'
    define_task do |t|
      t.address = address
    end
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(address: address)))
  end

  def stub_ruby_vault
    allow(RubyVault).to(receive(:login))
  end
end
