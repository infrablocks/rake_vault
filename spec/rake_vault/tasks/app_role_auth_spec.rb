# frozen_string_literal: true

require 'spec_helper'

describe RakeVault::Tasks::AppRoleAuth do
  include_context 'rake'

  before do
    namespace :vault do
      task :ensure
    end
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :app_role }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds an app role auth task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('app_role:login'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['app_role:login'].full_comment)
      .to(eq('Login with app role using vault'))
  end

  it 'allows multiple login tasks to be declared' do
    define_task(namespace: :app_role1)
    define_task(namespace: :app_role2)

    expect(Rake.application).to(have_task_defined('app_role1:login'))
    expect(Rake.application).to(have_task_defined('app_role2:login'))
  end

  it 'depends on the vault:ensure task by default' do
    define_task

    expect(Rake::Task['app_role:login'].prerequisite_tasks)
      .to(include(Rake::Task['vault:ensure']))
  end

  it 'passes a path parameter of auth/approle/login to write by default' do
    define_task
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(path: 'auth/approle/login')))
  end

  it 'passes the provided value for the path parameter to write ' \
     'when present' do
    path = 'auth/differentapprole/login'
    define_task do |t|
      t.path = path
    end
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(path: path)))
  end

  it 'does not pass role_id to write within data parameter ' \
     'when role_id is nil' do
    define_task do |t|
      t.role_id = nil
    end
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(
                    data: excluding(a_string_including('role_id='))
                  )))
  end

  it 'passes the provided role_id to write within data parameter ' \
     'when present' do
    define_task do |t|
      t.role_id = 'some-role-id'
    end
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(
                    data: including('role_id=some-role-id')
                  )))
  end

  it 'does not pass secret_id to write within data parameter ' \
     'when secret_id is nil' do
    define_task do |t|
      t.secret_id = nil
    end
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(
                    data: excluding(a_string_including('secret_id='))
                  )))
  end

  it 'passes the provided secret_id to write within data parameter ' \
     'when present' do
    define_task do |t|
      t.secret_id = 'some-secret-id'
    end
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(
                    data: including('secret_id=some-secret-id')
                  )))
  end

  it 'passes format json to write by default' do
    define_task
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault)
      .to(have_received(:write)
            .with(hash_including(format: 'json')))
  end

  it 'configures RubyVault stdout and changes back after' do
    define_task
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RubyVault).to(have_received(:configure).twice)
  end

  it 'writes token to file' do
    define_task
    stub_ruby_vault
    stub_token_file

    Rake::Task['app_role:login'].invoke

    expect(RakeVault::TokenFile)
      .to(have_received(:write).with(anything))
  end

  def stub_ruby_vault
    allow(RubyVault).to(receive(:write))
    allow(RubyVault).to(receive(:configure))
  end

  def stub_token_file
    allow(RakeVault::TokenFile).to(receive(:write))
  end
end
