# frozen_string_literal: true

require 'spec_helper'

describe RakeVault::TokenFile do
  describe 'write' do
    it 'writes token from json to ~/.vault-token' do
      file = create_file_double
      token = 'abc.123secure'
      json = "{\"auth\": {\"client_token\": \"#{token}\"}}"
      # stringIo = StringIO.new.write(json)

      described_class.write(json)

      expect(File).to(have_received(:open).with('~/.vault-token', 'w'))
      expect(file).to(have_received(:write).with(token))
      expect(file).to(have_received(:close))
    end
  end

  describe 'write_token_to_file' do
    it 'writes token to ~/.vault-token' do
      file = create_file_double
      token = 'abc.123secure'

      described_class.write_token_to_file(token)

      expect(File).to(have_received(:open).with('~/.vault-token', 'w'))
      expect(file).to(have_received(:write).with(token))
      expect(file).to(have_received(:close))
    end
  end

  def create_file_double
    file = instance_double(File, 'file')
    allow(File).to receive(:open).and_return(file)
    allow(file).to receive(:write)
    allow(file).to receive(:close)
    file
  end
end
