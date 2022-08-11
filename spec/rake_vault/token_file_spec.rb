# frozen_string_literal: true

require 'spec_helper'

describe RakeVault::TokenFile do
  describe 'write' do
    it 'writes token from json to ~/.vault-token' do
      path = '/home/user/.vault-token'
      file = create_file_double(path)
      token = 'abc.123secure'
      json = "{\"auth\": {\"client_token\": \"#{token}\"}}"

      described_class.write(json)

      expect(File).to(have_received(:open).with(path, 'w'))
      expect(file).to(have_received(:write).with(token))
      expect(file).to(have_received(:close))
    end
  end

  def create_file_double(path)
    file = instance_double(File, 'file')
    allow(File).to receive(:expand_path).and_return(path)
    allow(File).to receive(:open).and_return(file)
    allow(file).to receive(:write)
    allow(file).to receive(:close)
    file
  end
end
