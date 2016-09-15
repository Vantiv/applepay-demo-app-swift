require 'sinatra'
require 'json'
require 'open-uri'
require 'net/http'

#This makes Sinatra listen for outside connections
set :bind, '0.0.0.0'

post '/', :provides => :json do
  pass unless request.accept? 'application/json'
  @jsonStr = request.body.read
  #puts @jsonStr
  @json = JSON.parse(@jsonStr)
  #puts @json
  @json.to_s
  
  puts "Running transaction of " + @json["amount"] + " for " + @json["description"] + " using RegistrationId " + @json["registrationId"]

  uri = URI.parse("https://w1.mercurycert.net")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  ipRequest = Net::HTTP::Post.new("/PaymentsAPI/Credit/SaleByRecordNo")
  ipRequest.add_field('Content-Type', 'application/json')
  ipRequest.add_field('Accept', '*/*')
  ipRequest.add_field('Authorization', 'Basic NzU1ODQ3MDA3Onh5eg==')
  
  ipRequest.body =
    { 
      'InvoiceNo' => '123456',
      'Purchase' => @json["amount"],
      'TokenType' => 'RegistrationId',
      'RecordNo' => @json["registrationId"],
      'Frequency' => 'OneTime'
    }.to_json

  response = http.request(ipRequest)
  response.body
end
