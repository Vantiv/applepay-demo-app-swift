//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Alec Paulson on 8/17/16.
//  Copyright © 2016 Vantiv. All rights reserved.
//

import UIKit
import PassKit

class ItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover]
    let ApplePayMerchantID = "merchant.com.vantiv.applepaydemo"
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
        completion(PKPaymentAuthorizationStatus.Success)
        //let pkpaymenttoken = payment.token
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
