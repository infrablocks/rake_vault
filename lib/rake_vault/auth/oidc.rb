# frozen_string_literal: true

require 'ruby_vault'

module RakeVault
  module Auth
    module Oidc
      def self.login(address, role, no_print)
        auth = role ? ["role=#{role}"] : []

        RubyVault.login(
          method: 'oidc',
          auth: auth,
          address: address,
          no_print: no_print
        )
      end
    end
  end
end
