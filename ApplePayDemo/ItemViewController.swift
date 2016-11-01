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
    var merchantServerAddress: String = ""
    var merchantServerPort: String = ""
    var paypageId: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        applePayButton.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedPaymentNetworks)
        
        // Set up item
        if let item = item {
            navigationItem.title = item.name
            nameLabel.text   = item.name
            photoImageView.image = item.photo
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            priceLabel.text = formatter.string(from: item.price)
        }
        
        // Read settings from plist
        let path = Bundle.main.path(forResource: "Settings", ofType: "plist")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
        let dict = plist as! [String:String]
        merchantServerAddress = dict["merchantServerAddress"]!
        merchantServerPort = dict["merchantServerPort"]!
        paypageId = dict["paypageId"]!
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
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "host": "request-prelive.np-securepaypage-litle.com/LitlePayPage/paypage",
            "user-agent": "Litle/1.0 CFNetwork/459 Darwin/10.0.0.d3",
            "cache-control": "no-cache"
        ]
        
        let postData = NSMutableData(data: "paypageId=\(paypageId)".data(using: String.Encoding.utf8)!)
        postData.append("&reportGroup=testReportGroup".data(using: String.Encoding.utf8)!)
        postData.append("&orderId=testOrderId".data(using: String.Encoding.utf8)!)
        postData.append("&id=00000".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.data=\(data.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.signature=\(signature.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.version=\(version.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.header.ephemeralPublicKey=\(ephemeralPublicKey.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.header.publicKeyHash=\(publicKeyHash.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.header.transactionId=\(transactionId.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
        postData.append("&applepay.header.applicationData=\(applicationData.stringByAddingPercentEncodingForRFC3986()!)".data(using: String.Encoding.utf8)!)
 
        let request = NSMutableURLRequest(url: NSURL(string: "https://request-prelive.np-securepaypage-litle.com/LitlePayPage/paypage")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                print(self.convertStringToDictionary(text: NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)!["paypageRegistrationId"]!)
                
                let jsonResponse = self.convertStringToDictionary(text: NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)!
                let registrationId = jsonResponse["paypageRegistrationId"]!
                
                //pass regid + order info to
                //merchant server: send txn to netepay
                //replace IP in next line with dev machine IP
                let merchantRequest = NSMutableURLRequest(url: URL(string: "http://\(self.merchantServerAddress):\(self.merchantServerPort)")!)
                merchantRequest.httpMethod = "POST"
                merchantRequest.addValue("application/json", forHTTPHeaderField: "Accept")
                
                let nf = NumberFormatter()
                nf.numberStyle = .decimal
                
                let merchantJson =
                    [
                        "registrationId":registrationId,
                        "amount": nf.string(from: self.item!.price.adding(self.ShippingPrice))!,
                        "description": self.item!.name
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
            }
        })
        
        dataTask.resume()
        
        
        
        //TODO: Handle error condition
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func convertStringToDictionary(text: NSString) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8.rawValue) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}
