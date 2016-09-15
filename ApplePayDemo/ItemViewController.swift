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
    
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover]
    let ApplePayMerchantID = "merchant.com.mercury.prelive"
    let ShippingPrice : NSDecimalNumber = NSDecimalNumber(string: "5.0")
    var item: Item?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        applePayButton.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedPaymentNetworks)
        
        // Set up views if editing an existing Meal.
        if let item = item {
            navigationItem.title = item.name
            nameLabel.text   = item.name
            photoImageView.image = item.photo
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            priceLabel.text = formatter.string(from: item.price)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        //request.requiredBillingAddressFields = PKAddressField.All
        request.requiredShippingAddressFields = PKAddressField.all
        
        //request.applicationData = "This is a test".dataUsingEncoding(NSUTF8StringEncoding)
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: item!.name, amount: item!.price),
            PKPaymentSummaryItem(label: "Shipping", amount: ShippingPrice),
            PKPaymentSummaryItem(label: "Demo Merchant", amount: item!.price.adding(ShippingPrice))
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self;
        
        self.present(applePayController, animated: true, completion: nil)
    }
}

extension ItemViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        let pkPaymentToken = payment.token
        //pkPaymentToken.paymentData //base64 encoded, applepay.data
        
        let json = try? JSONSerialization.jsonObject(with: pkPaymentToken.paymentData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
        
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
        var eProtectRequest = URLRequest(url: URL(string: "https://request-prelive.np-securepaypage-litle.com/LitlePayPage/paypage")!)
        eProtectRequest.httpMethod = "POST"
        eProtectRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        eProtectRequest.addValue("request-prelive.np-securepaypage-litle.com/LitlePayPage/paypage", forHTTPHeaderField: "Host")
        eProtectRequest.addValue("Litle/1.0 CFNetwork/459 Darwin/10.0.0.d3", forHTTPHeaderField: "User-Agent")
        let postString =
            "paypageId=KjJkn9DXJjdesuBf" +
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
                
        eProtectRequest.httpBody = postString.data(using: String.Encoding.utf8)
        
        let eProtectTask = URLSession.shared.dataTask(with: eProtectRequest as URLRequest, completionHandler: { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
        
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
        
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
        }) 
        eProtectTask.resume()
        
        //pass regid + order info to
        //merchant server: send txn to netepay
        //replace IP in next line with dev machine IP
        let merchantRequest = NSMutableURLRequest(url: URL(string: "http://10.137.241.36:4567")!)
        merchantRequest.httpMethod = "POST"
        merchantRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        let merchantJson =
            [
                "registrationId":"0000000000000000000",
                "amount": nf.string(from: item!.price.adding(ShippingPrice))!,
                "description": item!.name
            ] as [String : Any]
        merchantRequest.httpBody = try? JSONSerialization.data(withJSONObject: merchantJson, options: .prettyPrinted)

        let merchantTask = URLSession.shared.dataTask(with: merchantRequest as URLRequest, completionHandler: { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
        }) 
        merchantTask.resume()
        
        //TODO: Handle error condition
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
