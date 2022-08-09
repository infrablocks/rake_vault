# frozen_string_literal: true

require 'spec_helper'

describe RakeVault::Tasks::AppRoleAuth do
  include_context 'rake'

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
end
