//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Alec Paulson on 8/17/16.
//  Copyright © 2016 Alec Paulson. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController {

    @IBOutlet var applePayButton: UIButton!
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover]
    let ApplePayMerchantID = "merchant.com.vantiv.applepaydemo"
    let ShippingPrice : NSDecimalNumber = NSDecimalNumber(string: "5.0")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func buttonPressed(sender: AnyObject) {
        print("buttonPressed!")
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        //request.requiredBillingAddressFields = PKAddressField.All
        request.requiredShippingAddressFields = PKAddressField.All
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Vantiv T-Shirt", amount: 5.00),
            PKPaymentSummaryItem(label: "Shipping", amount: ShippingPrice),
            PKPaymentSummaryItem(label: "Demo Merchant", amount: NSDecimalNumber(string: "5.0").decimalNumberByAdding(ShippingPrice))
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self;
        
        self.presentViewController(applePayController, animated: true, completion: nil)
    }
}

extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        completion(PKPaymentAuthorizationStatus.Success)
        let pkpaymenttoken = payment.token
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
