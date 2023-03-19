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
  addresses = []
  CSV.foreach(filename, headers: true) do |row|
    address_request = SmartyStreets::USStreet::Lookup.new
    address_request.street = row['Street']
    address_request.city = row['City']
    address_request.zipcode = row['Zip Code']
    addresses << { initial_address: address_request, corrected_address: nil }
  end
  addresses
end


def send_batch(client, addresses)
  batch = SmartyStreets::Batch.new
  addresses.each do |addr|
    batch.add(addr[:initial_address])
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
    original_address = "#{addresses[idx][:initial_address].street}, #{addresses[idx][:initial_address].city}, #{addresses[idx][:initial_address].zipcode}"
    if candidates.empty? || candidates.nil?
      pp "#{original_address} -> Invalid Address"
    else
      full_corrected_address = "#{candidates[0].components.primary_number} #{candidates[0].components.street_name} #{candidates[0].components.street_suffix}, #{candidates[0].components.city_name}, #{candidates[0].components.zipcode}-#{candidates[0].components.plus4_code}"
      
      pp "#{original_address} -> #{full_corrected_address}"
    end
  end
end

# MAIN
filename = ARGV[0]
client = setup_client
addresses = parse_addresses(filename)
batch = send_batch(client, addresses)
process_results(addresses, batch)


