# frozen_string_literal: true

require 'ruby_vault'
require 'spec_helper'

describe RakeVault::Tasks::OidcAuth do
  include_context 'rake'

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

  it 'passes method oidc to login' do
    define_task
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(method: 'oidc')))
  end

  it 'passes the provided value for the role parameter to login when present' do
    role = 'some-role'
    define_task do |t|
      t.role = role
    end
    stub_ruby_vault

    Rake::Task['oidc:login'].invoke

    expect(RubyVault)
      .to(have_received(:login)
            .with(hash_including(role: role)))
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
