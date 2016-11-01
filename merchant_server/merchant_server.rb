require 'sinatra'
require 'json'
require 'open-uri'
require 'net/http'
require 'yaml'

#This makes Sinatra listen for outside connections
set :bind, '0.0.0.0'

settings = YAML.load(File.open('settings.yml'))

post '/', :provides => :json do
  pass unless request.accept? 'application/json'
  @jsonStr = request.body.read
  #puts @jsonStr
  @json = JSON.parse(@jsonStr)
  #puts @json
  @json.to_s
  
  puts "Running transaction of " + @json["amount"] + " for " + @json["description"] + " using RegistrationId " + @json["registrationId"]

  uri = URI.parse(settings["uri"])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  ipRequest = Net::HTTP::Post.new("/PaymentsAPI/Credit/SaleByRecordNo")
  ipRequest.add_field('Content-Type', 'application/json')
  ipRequest.add_field('Accept', '*/*')
  ipRequest.add_field('Authorization', 'Basic ' + settings["auth"])
  
  ipRequest.body =
    {
      'OperatorID' => 'TEST',
      'InvoiceNo' => '123456',
      'Purchase' => @json["amount"],
      'TokenType' => 'RegistrationId',
      'RecordNo' => @json["registrationId"],
      'Frequency' => 'OneTime'
    }.to_json

  response = http.request(ipRequest)
  response.body
end
