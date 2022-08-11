# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakeVault do
  it 'has a version number' do
    expect(RakeVault::VERSION).not_to be_nil
  end

  describe '.define_oidc_auth_task' do
    context 'when instantiating RakeVault::Task::OidcAuth' do
      it 'passes the provided options and block' do
        opts = {}
        block = ->(_t) do end
        allow(RakeVault::Tasks::OidcAuth).to(receive(:define))

        described_class.define_oidc_auth_task(opts, &block)

        expect(RakeVault::Tasks::OidcAuth)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
    end
  end

  describe '.define_app_role_auth_task' do
    context 'when instantiating RakeVault::Task::AppRoleAuth' do
      it 'passes the provided options and block' do
        opts = {}
        block = ->(_t) do end
        allow(RakeVault::Tasks::AppRoleAuth).to(receive(:define))

        described_class.define_app_role_auth_task(opts, &block)

        expect(RakeVault::Tasks::AppRoleAuth)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
    end
  end

  describe '.define_installation_tasks' do
    context 'when setting up tasks for vault installation' do
      it 'sets the namespace to vault by default' do
        task_set = described_class.define_installation_tasks

        expect(task_set.namespace).to(eq('vault'))
      end

      it 'uses the supplied namespace when provided' do
        task_set = described_class.define_installation_tasks(
          namespace: :tools_vault
        )

        expect(task_set.namespace).to(eq('tools_vault'))
      end

      it 'sets the dependency to vault' do
        task_set = described_class.define_installation_tasks

        expect(task_set.dependency).to(eq('vault'))
      end

      it 'sets the version to 1.10.4 by default' do
        task_set = described_class.define_installation_tasks

        expect(task_set.version).to(eq('1.10.4'))
      end

      it 'uses the supplied version when provided' do
        task_set = described_class.define_installation_tasks(
          version: '1.9.7'
        )

        expect(task_set.version).to(eq('1.9.7'))
      end

      it 'uses a path of `pwd`/vendor/vault by default' do
        task_set = described_class.define_installation_tasks

        expect(task_set.path)
          .to(eq("#{Dir.pwd}/vendor/vault"))
      end

      it 'uses the supplied path when provided' do
        task_set = described_class.define_installation_tasks(
          path: File.join('tools', 'vault')
        )

        expect(task_set.path)
          .to(eq(File.join('tools', 'vault')))
      end

      it 'uses a type of zip' do
        task_set = described_class.define_installation_tasks

        expect(task_set.type).to(eq(:zip))
      end

      it 'uses platform OS names of darwin, linux and windows' do
        task_set = described_class.define_installation_tasks

        expect(task_set.platform_os_names)
          .to(eq({
                   darwin: 'darwin',
                   linux: 'linux',
                   mswin32: 'windows',
                   mswin64: 'windows'
                 }))
      end

      # rubocop:disable Naming/VariableNumber
      it 'uses the correct platform CPU names' do
        task_set = described_class.define_installation_tasks

        expect(task_set.platform_cpu_names)
          .to(eq({
                   x86_64: 'amd64',
                   x86: '386',
                   x64: 'amd64',
                   arm64: 'arm64'
                 }))
      end
      # rubocop:enable Naming/VariableNumber

      it 'uses the correct URI template' do
        task_set = described_class.define_installation_tasks

        expect(task_set.uri_template)
          .to(eq('https://releases.hashicorp.com/vault/' \
                 '<%= @version %>/vault_<%= @version %>_' \
                 '<%= @platform_os_name %>_<%= @platform_cpu_name %>' \
                 '<%= @ext %>'))
      end

      it 'uses the correct file name template' do
        task_set = described_class.define_installation_tasks

        expect(task_set.file_name_template)
          .to(eq('vault_<%= @version %>_' \
                 '<%= @platform_os_name %>_<%= @platform_cpu_name %>' \
                 '<%= @ext %>'))
      end

      # TODO: test needs_fetch more thoroughly
      it 'provides a needs_fetch checker' do
        task_set = described_class.define_installation_tasks

        expect(task_set.needs_fetch).not_to(be_nil)
      end
    end
  end
end
