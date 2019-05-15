/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import Simplify

class PaymentViewController: UIViewController {

    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardEntryView: CardEntryView!
    @IBOutlet var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCardEntryView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cardEntryView.reset()
    }

    // MARK: - Submit Action
    // Calls Simplify to create a card token
    @IBAction func submit(_ sender: UIButton) {
        _ = cardEntryView.resignFirstResponder()
        activityView.isHidden = false
        
        // Create & populate the card object from custom card entry view
        // let card = SimplifyMap(map: ["number" : "5555555555554442","expMonth" : 6,"expYear" : 19,"cvc" : "123"])
        
        // Get the card object from the provided card entry view
        let card = cardEntryView.card
        
        // To process 3DS your account needs to be enabled for 3DS & include the payload with payment details
        let threeDSData = SimplifyMap(map: ["amount": 1500, "currency": "AUD", "description": "Test"])
        
        do {
            // Instantiate an instance of the Simplify Object
            let simplify = try Simplify(apiKey: "<#Your API Public Key#>")
            // Send a request to create a card token and handle the response
            simplify.createCardToken(card: card, secure3DRequestData: threeDSData) { (result) in
                // Handle the response on the main queue
                DispatchQueue.main.async() { self.cardTokenResponseHandler(result) }
            }
        } catch {
            self.presentResultViewController(status: .failure)
        }
    }
    
    // MARK: - Handle Card Token Response
    func cardTokenResponseHandler(_ result: Result<SimplifyMap>) {
        // Hide the activity indicator
        activityView.isHidden = true
        
        switch (result) {
        case .success(let cardToken):
            print("\n ----- Token Success ----- \n \(cardToken) \n --------------------")
            // If the cardToken indicates that it is enrolled in 3DS, present the 3DS auth
            if cardToken.card.secure3DData.isEnrolled.boolValue == true {
                presentWebview3DSAuth(token: cardToken)
            } else {
                // If NOT enrolled, the card token does not need authentication, so you can pass the token to your server to process a payment
                presentResultViewController(status: .success)
            }
        case .failure(let error):
            // Handle the error
            print("\n ----- Token Error ----- \n \(error.localizedDescription) \n --------------------")
            presentResultViewController(status: .failure)
        }
    }
    
    // MARK: - Perform 3DS 1.0 Authentication
    func presentWebview3DSAuth(token: SimplifyMap) {
        // Construct the ThreeDS1WebViewController and present it
        let webView = ThreeDS1WebViewController(nibName: nil, bundle: nil)
        navigationController?.pushViewController(webView, animated: true)
        // Set ourselves as the delegate
        webView.delegate = self
        do {
            // Attempt to authenticate
            try webView.authenticate(with: token)
        } catch (let error) {
            print("\n ----- 3DS 1.0 Web View Error ----- \n \(error.localizedDescription) \n --------------------")
            presentResultViewController(status: .failure)
        }
    }
    
    func presentResultViewController(status: tokenResult) {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resultViewController") as! ResultViewController
        view.status = status
        navigationController?.pushViewController(view, animated: true)
    }
    
    @IBAction func unwindToPayment(_ sender: UIStoryboardSegue) {
        // Clear the Card Entry View
        cardEntryView.reset()
    }
}

// MARK: - Card Entry View Configuration
extension PaymentViewController {
    // Card Entry View specfic configuration
    
    func configureCardEntryView() {
        // Configure submit button on first load
        buttonSubmit.isEnabled = cardEntryView.isValid
        
        // Set up methods to allow the user to only submit the card information if the information passes Luhn Check
        cardEntryView.addTarget(self, action: #selector(cardDidChange(_:)), for: .valueChanged)
    }
    
    @IBAction func cardDidChange(_ sender: Any) {
        // Disable the submit button if the card is not valid yet
        buttonSubmit.isEnabled = cardEntryView.isValid
    }
}

// MARK: - ThreeDS1WebViewControllerDelegate Methods
extension PaymentViewController: ThreeDS1WebViewControllerDelegate {
    func threeDS1WebViewController(_ threeDSView: ThreeDS1WebViewController, didError error: String, for cardToken: SimplifyMap) {
        print("\n ----- 3DS 1.0 Error ----- \n \(error) \n --------------------")
        self.presentResultViewController(status: .failure)
    }
    
    func threeDS1WebViewController(_ threeDSView: ThreeDS1WebViewController, didReceiveACSAuthResult authenticated: Bool, for cardToken: SimplifyMap) {
        threeDSView.dismiss(animated: true, completion: nil)
        print("\n ----- 3DS 1.0 Result ----- \n authenticated: \(authenticated) \n --------------------")
        
        if authenticated {
            // Proceed with processing the card token here
            self.presentResultViewController(status: .success)
        } else {
            // Handle any errors you recieve and display a response message
            self.presentResultViewController(status: .failure)
        }
    }
    
    func threeDS1WebViewControllerDidCancel(_ threeDSView: ThreeDS1WebViewController) {
        // Handle the user stopping 3DS Authentication with a response message
        self.navigationController?.popViewController(animated: true)
    }
}

extension PaymentViewController {
    func createActivityAlert(title: String? = nil, message: String? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alert
    }
}
