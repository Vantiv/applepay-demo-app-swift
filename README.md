# applepay-demo-app-swift

Apple Pay App demonstrating how to integrate to Vantiv Integrated Payments

# Setup (Work In Progress)

* Set up apple pay in developer account

* Create merchant id/app id

* Install Xcode (of course) - Currently using 8.0

## Simulating the Merchant Server

Following are needed for locally simulating a merchant server for the app to communicate with.

Execute commands from the Terminal

### Install Brew

If it asks you to install XCode CommandLine Tools, say yes.

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

### Upgrade Ruby

`brew install ruby`

### Install Sinatra

`gem install sinatra`

### Update settings.yml

Update `auth` with Base64 encoded credentials provided by Vantiv Integrated Payments

### To run the Sinatra REST site

`ruby merchant_server.rb`

NOTE: Use `control+c` to quit the web server

## Before running App in XCode

* Update `Settings.plist` with values for

  * `merchantServerAddress` - this will be the external ip address of the machine running the `merchant_server.rb` script
  * `paypageId` - provided by Vantiv Integrated Payments

## Run App in Xcode

* Must run app on iOS device w/ ApplePay support

* Device must be on same network as dev machine

* Change line in ItemViewController.swift:130 with IP address of development machine
