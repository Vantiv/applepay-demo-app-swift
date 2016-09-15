//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Alec Paulson on 8/17/16.
//  Copyright © 2016 Vantiv. All rights reserved.
//

import UIKit
import PassKit
import Dispatch

class ItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover]
    let ApplePayMerchantID = "merchant.com.mercury.prelive"
    let ShippingPrice : NSDecimalNumber = NSDecimalNumber(string: "5.0")
    var item: Item?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        
        // Set up views if editing an existing Meal.
        if let item = item {
            navigationItem.title = item.name
            nameLabel.text   = item.name
            photoImageView.image = item.photo
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            priceLabel.text = formatter.stringFromNumber(item.price)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    @IBAction func buttonPressed(sender: AnyObject) {
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        //request.requiredBillingAddressFields = PKAddressField.All
        request.requiredShippingAddressFields = PKAddressField.All
        
        //request.applicationData = "This is a test".dataUsingEncoding(NSUTF8StringEncoding)
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: item!.name, amount: item!.price),
            PKPaymentSummaryItem(label: "Shipping", amount: ShippingPrice),
            PKPaymentSummaryItem(label: "Demo Merchant", amount: item!.price.decimalNumberByAdding(ShippingPrice))
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self;
        
        self.presentViewController(applePayController, animated: true, completion: nil)
    }
}

extension ItemViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        let pkPaymentToken = payment.token
        pkPaymentToken.paymentData //base64 encoded, applepay.data
        
        let json = try? NSJSONSerialization.JSONObjectWithData(pkPaymentToken.paymentData, options: NSJSONReadingOptions.AllowFragments)
        
        let version = json!["version"] as! String
        let data = json!["data"] as! String
        let signature = json!["signature"] as! String
        let ephemeralPublicKey = (json!["header"] as! [String: String])["ephemeralPublicKey"]! as String
        var applicationData: String = ""
        if let appData = (json!["header"] as! [String: String])["applicationData"] {
            applicationData = appData
        }
        let publicKeyHash = (json!["header"] as! [String: String])["publicKeyHash"]! as String
        let transactionId = (json!["header"] as! [String: String])["transactionId"]! as String
                
        //call eprotect with paymentData
        let eProtectRequest = NSMutableURLRequest(URL: NSURL(string: "https://request-prelive.np-securepaypage-litle.com/LitlePayPage/paypage")!)
        eProtectRequest.HTTPMethod = "POST"
        eProtectRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        eProtectRequest.addValue("request-prelive.np-securepaypage-litle.com/LitlePayPage/paypage", forHTTPHeaderField: "Host")
        eProtectRequest.addValue("Litle/1.0 CFNetwork/459 Darwin/10.0.0.d3", forHTTPHeaderField: "User-Agent")
        let postString =
            "paypageId=***REMOVED***" +
                "&reportGroup=testReportGroup" +
                "&orderId=testOrderId" +
                "&id=00000" +
                "&applePay.data=\(data)" +
                "&applePay.signature=\(signature)" +
                "&applePay.version=\(version)" +
                "&applePay.header.applicationData=\(applicationData)" +
                "&applePay.header.ephermeralPublicKey=\(ephemeralPublicKey)" +
                "&applePay.header.publicKeyHash=\(publicKeyHash)" +
                "&applePay.header.transactionId=\(transactionId)"
                
        eProtectRequest.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let eProtectTask = NSURLSession.sharedSession().dataTaskWithRequest(eProtectRequest) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
        
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
        
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        eProtectTask.resume()
        
        //pass regid + order info to
        //merchant server: send txn to netepay
        let merchantRequest = NSMutableURLRequest(URL: NSURL(string: "http://localhost:4567")!)
        merchantRequest.HTTPMethod = "POST"
        merchantRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let ipJson =
            [
                "registrationId":"0000000000000000000",
                "amount": item!.price.decimalNumberByAdding(ShippingPrice),
                "description": item!.name
            ]
        merchantRequest.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(ipJson, options: .PrettyPrinted)

        let merchantTask = NSURLSession.sharedSession().dataTaskWithRequest(eProtectRequest) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        merchantTask.resume()
        
        //TODO: Handle error condition
        completion(PKPaymentAuthorizationStatus.Success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        //controller.dismissViewControllerAnimated(true, completion: nil)
        
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completionHandler!(success: true)
                } else {
                    self.completionHandler!(success: false)
                }
            }
        }
    }
}
