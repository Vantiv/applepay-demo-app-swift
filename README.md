# applepay-demo-app-swift

Apple Pay iOS App demonstrating how to integrate to Vantiv Integrated Payments

# Prerequisites

* [Apple Developer Account](https://developer.apple.com/programs/)

* [Vantiv Integrated Payments Cert Account](https://www.vantiv.com)

* Tokenization Enabled
* WebServices Enabled

* [Vantiv eProtect Paypage ID](https://www.vantiv.com)

* EWSv4 Support

# Setup

* Set up Apple Pay in developer account

* Create merchant id/app id

* Install Xcode - Currently using 8.1

## Simulating the Merchant Server

Following are needed for locally simulating a merchant server for the app to communicate with.

Execute commands from the Terminal

### Install Brew

If it asks you to install XCode CommandLine Tools, say yes.

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

### Install Ruby

`brew install ruby`

### Install Sinatra

`gem install sinatra`

### Update settings.yml

Update `auth` with Base64 encoded credentials provided by Vantiv Integrated Payments

### To run the Sinatra REST site

`ruby merchant_server.rb`

NOTE: Use `control+c` to quit the web server

## Before running App in Xcode

* Update `Settings.plist` with values for

* `merchantServerAddress` - this will be the external ip address of the machine running the `merchant_server.rb` script
* `paypageId` - provided by Vantiv Integrated Payments

## Run App in Xcode

* Must run app on iOS device w/ ApplePay support
* [Instructions for setting up Test Cards](https://developer.apple.com/support/apple-pay-sandbox/)

* __Device must be on same network as machine running `merchant_server.rb` script__
