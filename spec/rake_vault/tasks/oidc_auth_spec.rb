# frozen_string_literal: true

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
end
