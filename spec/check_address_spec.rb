require 'spec_helper'
require_relative '../check_address'

describe 'CheckAddress' do
  describe '#setup_client' do
    it 'returns a client object' do
      client = setup_client
      expect(client).to be_instance_of(SmartyStreets::USStreet::Client)
    end
  end

  describe '#parse_addresses' do
    it 'returns an array of addresses' do
      filename = 'spec/fixtures/sample.csv'
      addresses = parse_addresses(filename)
      expect(addresses).to be_an(Array)
      expect(addresses.length).to eq(4)
      expect(addresses.first[:address_lookup]).to be_a(SmartyStreets::USStreet::Lookup)
    end
  end

  describe '#send_batch' do
    it 'returns a batch object with corrected addresses' do
      client = setup_client
      filename = 'spec/fixtures/sample.csv'
      addresses = parse_addresses(filename)
      batch = send_batch(client, addresses)
      expect(batch).to be_a(SmartyStreets::Batch)
      expect(batch.all_lookups.size).to eq(4)
      #last item in the sample csv is valid but needs some correction
      expect(batch.all_lookups.last.result).to_not be_empty
    end
  end

  describe '#process_results' do
    it 'returns a hash of original and corrected addresses' do
      #setup to process
      client = setup_client
      filename = 'spec/fixtures/sample.csv'
      addresses = parse_addresses(filename)
      batch = send_batch(client, addresses)
      #process results
      results = process_results(addresses, batch)
      expect(results).to be_an(Array)
      expect(results.length).to eq(4)
      expect(results.first[:original_address]).to eq('3901 Sherman Street, Ozawkie, 66070')
      expect(results.first[:corrected_address]).to eq('Invalid')
      #the first three addresses in sample.csv are invalid, the last is a valid address that needs some correction
      #corrections needed are drive needs to be shortened to dr, first letters in names should be capitalized, and plus4 zip
      expect(results.last[:original_address]).to eq('4528 university drive, ooltewah, 37363')
      expect(results.last[:corrected_address]).to eq('4528 University Dr, Ooltewah, 37363-8514')
    end
  end
end