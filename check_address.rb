require 'csv'                                               
require 'smartystreets_ruby_sdk'
require 'pry'
require 'dotenv/load'

def setup_client
  credentials = SmartyStreets::StaticCredentials.new(ENV['AUTH_ID'], ENV['AUTH_TOKEN']) 
  client = SmartyStreets::ClientBuilder.new(credentials).build_us_street_api_client
end

# Open the CSV file and read in the addresses
def parse_addresses(filename)
  #make an empty array of addresses, addresses will be hashes, so this will be an array of hashes.
  addresses = []
  CSV.foreach(filename, headers: true) do |row|
    #make a new lookup
    address_request = SmartyStreets::USStreet::Lookup.new
    #set original address
    original_address = "#{row['Street']}, #{row['City']}, #{row['Zip Code']}"
    #fill out lookup fields
    address_request.street = row['Street']
    address_request.city = row['City']
    address_request.zipcode = row['Zip Code']
    #push hash onto addresses array that includes lookup, corrected_address (for later) and original_address
    addresses << { address_lookup: address_request, corrected_address: nil, original_address: original_address }
  end
  addresses
end


def send_batch(client, addresses)
  batch = SmartyStreets::Batch.new
  addresses.each do |addr|
    batch.add(addr[:address_lookup])
  end
  begin
    client.send_batch(batch)
  rescue SmartyStreets::SmartyError => err
    puts err
    return
  end
  batch
end

def process_results(addresses, batch)
  batch.each_with_index do |lookup, idx|
    candidates = lookup.result
    original_address = "#{addresses[idx][:original_address]}"
    if candidates.empty? || candidates.nil?
      #pretty print original address -> invalid
      pp "#{original_address} -> Invalid Address"
      #add invalid in corrected address place, this is mostly to make testing easier
      addresses[idx][:corrected_address] = "Invalid"
    else
      #get full corrected address
      full_corrected_address = "#{candidates[0].components.primary_number} #{candidates[0].components.street_name} #{candidates[0].components.street_suffix}, #{candidates[0].components.city_name}, #{candidates[0].components.zipcode}-#{candidates[0].components.plus4_code}"
      #add corrected address to address hash, this is mostly to make testing easier.
      addresses[idx][:corrected_address] = full_corrected_address
      #pretty print address -> corrected address
      pp "#{original_address} -> #{full_corrected_address}"
    end
  end
  pp addresses
end

# MAIN
filename = ARGV[0]
client = setup_client
addresses = parse_addresses(filename)
batch = send_batch(client, addresses)
process_results(addresses, batch)


