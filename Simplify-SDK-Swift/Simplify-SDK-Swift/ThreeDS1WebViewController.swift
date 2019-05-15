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


/// A protocol for observing the status of the 3DS 1.0 transaction being authenticated with a `ThreeDS1WebViewController`
public protocol ThreeDS1WebViewControllerDelegate {
    
    /// Called when 3DS 1.0 authentication for the transaction is completed.
    ///
    /// - Parameters:
    ///   - threeDSView: The `ThreeDS1WebViewController` that called the delegate.  This useful for dismissing the view.
    ///   - authenticated: The the result of authentication for the transaction.
    ///   - for cardToken: The card token that the view was authenticating.
    func threeDS1WebViewController(_ threeDSView: ThreeDS1WebViewController, didReceiveACSAuthResult authenticated: Bool, for cardToken: SimplifyMap)
    
    /// Called when 3DS 1.0 authentication for the transaction has errored.
    ///
    /// - Parameters:
    ///   - threeDSView: The `ThreeDS1WebViewController` that called the delegate.  This useful for dismissing the view.
    ///   - error: The error message from the 3ds authentication.
    ///   - for cardToken: The card token that the view was authenticating.
    func threeDS1WebViewController(_ threeDSView: ThreeDS1WebViewController, didError error: String, for cardToken: SimplifyMap)
    
    /// Called when the authentication is cancelled
    ///
    /// - Parameter threeDSView: The `ThreeDS1WebViewController` that called the delegate.  This useful for dismissing the view.
    func threeDS1WebViewControllerDidCancel(_ threeDSView: ThreeDS1WebViewController)
}


/// A view controller for performing 3DS 1.0 authentication.
public class ThreeDS1WebViewController: UIViewController {
    
    /// A delegate for being notified of completion or cancellation of the authentication.
    public var delegate: ThreeDS1WebViewControllerDelegate? = nil
    
    var currentToken: SimplifyMap = .default
    
    lazy var webView: WebView = lazyWebView()
    lazy var activityIndicator = lazyActivityIndicator()
    lazy var activityBarButtonItem = lazyActivityBarButtonItem()
    lazy var cancelButtonItem = lazyCancelBarButtonItem()
    lazy var primaryStackView = lazyStackView()
    lazy var navigationBar = lazyNavigationBar()
    
    var jsonDecoder: JSONDecoderProtocol = JSONDecoder()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        evaluateNavigationBar()
        activityIndicator.startAnimating()
        super.viewWillAppear(animated)
    }
    
    /// Initiate 3DS 1.0 authentication for the provided card token
    ///
    /// - Parameter cardToken: the card token containing the `secure3DData element.
    /// - Throws: A `SimplifyError` if the cardToken was missing the required data.
    public func authenticate(with cardToken: SimplifyMap) throws {
        currentToken = cardToken
        
        guard let acsUrl = cardToken.card.secure3DData.acsUrl.stringValue
            else { throw SimplifyError("Card token must contain 'card.secure3DData.acsUrl'") }
        guard let paReq = cardToken.card.secure3DData.paReq.stringValue
            else { throw SimplifyError("Card token must contain 'card.secure3DData.paReq'") }
        guard let md = cardToken.card.secure3DData.md.stringValue
            else { throw SimplifyError("Card token must contain 'card.secure3DData.md'") }
        guard let termUrl = cardToken.card.secure3DData.termUrl.stringValue
            else { throw SimplifyError("Card token must contain 'card.secure3DData.termUrl'") }
        
        let html = constructHTMLString(acsUrl: acsUrl, paReq: paReq, md: md, termsUrl: termUrl)
        
        _ = webView.loadHTMLString(html, baseURL: nil)
    }
}
