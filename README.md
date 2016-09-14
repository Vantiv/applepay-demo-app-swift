# applepay-demo-app-swift
Apple Pay App showing integration to Vantiv Integrated Payments

#Setup

Set up apple pay in developer account
Create merchant id/app id

Install XCode (of course) - Currently using 7.3.1

Following are needed for locally simulating a merchant server for the app to communicate with.

Execute commands from the Terminal

Install Brew - If it asks you to install XCode CommandLine Tools, say yes.

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Upgrade Ruby

brew install ruby

Install Sinatra

gem install sinatra

To run the sinatra REST site

ruby myapp.rb

control+c to quit

Run App in XCode
