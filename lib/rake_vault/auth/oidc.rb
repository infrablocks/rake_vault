# frozen_string_literal: true

require 'ruby_vault'

module RakeVault
  module Auth
    module Oidc
      def self.login(address, role, no_print)
        auth = role ? ["role=#{role}"] : []

        RubyVault.login(
          method: 'oidc',
          auth:,
          address:,
          no_print:
        )
      end
    end
  end
end
