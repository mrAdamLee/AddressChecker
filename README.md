# AddressChecker
This repository contains two files, check_address.rb and check_address_spec.rb.

## check_address.rb
Contains the implementation of a script that takes in a CSV file containing addresses and uses the SmartyStreets API to validate and correct the addresses. The corrected addresses are output to the console.

## Dependencies
This script requires the following dependencies to be installed:

csv: to read in the CSV file
smartystreets_ruby_sdk: to interact with the SmartyStreets API

pry: for debugging

dotenv: to load environment variables from a .env file

## Usage
To use this script, run the following command in your terminal:

``` ruby check_address.rb path/to/file.csv ```

Replace path/to/file.csv with the path to your CSV file.

## check_address_spec.rb
This file contains the RSpec tests for check_address.rb. It tests the various methods in the script to ensure they are working correctly.

## Dependencies
This test suite requires the following dependencies to be installed:

rspec: the testing framework

pry: for debugging

## Usage
To run the test suite, run the following command in your terminal:

``` rspec check_address_spec.rb ```

## Thought Process
The task was pretty straight forward, read in data from the csv, then check the address against the third party api. 
I figured do it in batches to save on api calls and the api supported it, since I had a relatively small data set I didn't
set a specific batch size though if this were scaled up at all we would want to specifiy a batch size. I used rspec for testing
since that is what I'm most familiar with.
