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
import WebKit

extension ThreeDS1WebViewController {
    func evaluateNavigationBar() {
        if navigationController != nil {
            navigationBar.isHidden = true
        } else {
            navigationBar.isHidden = false
            navigationBar.pushItem(navigationItem, animated: false)
        }
    }
    
    func setupNavigationItem() {
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        self.navigationItem.rightBarButtonItem = activityBarButtonItem
    }
    
    func setupView() {
        primaryStackView.addArrangedSubview(navigationBar)
        primaryStackView.addArrangedSubview(webView)
        self.view.addSubview(primaryStackView)
        NSLayoutConstraint.activate(primaryStackView.superviewHuggingConstraints(useMargins: false))
    }
    
    @objc func cancel() {
        delegate?.threeDS1WebViewControllerDidCancel(self)
    }
}

extension ThreeDS1WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.scheme == Constants.sdkScheme {
            handle3DSRedirect(redirect: components)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension ThreeDS1WebViewController {
    struct Constants {
        static var sdkScheme = "simplifysdk"
        static var resultQueryItem = "result"
    }
    
    func handle3DSRedirect(redirect components: URLComponents) {
        guard let result = components.queryItems?.first(where: { $0.name == Constants.resultQueryItem })?.value else {
            delegate?.threeDS1WebViewController(self, didError: "Unable to read 3DS result", for: currentToken)
            return
        }
        
        let resultData = Data(_: result.utf8)
        let resultMap = try? jsonDecoder.decode(SimplifyMap.self, from: resultData)
        if let result = resultMap?.secure3d.authenticated.boolValue {
            delegate?.threeDS1WebViewController(self, didReceiveACSAuthResult: result, for: currentToken)
        } else {
            delegate?.threeDS1WebViewController(self, didError: resultMap?.secure3d.error.stringValue ?? "Unable to read 3DS result", for: currentToken)
        }
    }
    
    func constructHTMLString(acsUrl: String, paReq: String, md: String, termsUrl: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en" dir="ltr">
        <head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
        <script> window.onload = function() { var html = '<form id="myform" method="post" enctype="application/x-www-form-urlencoded" action="\(acsUrl)" >' + '<input type="hidden" name="PaReq" value="\(paReq)" />' + '<input type="hidden" name="MD" value="\(md)" />' + '<input type="hidden" name="TermUrl" value="\(termsUrl)" />' + '</form>'; var iframe = document.getElementById('iframe'); var doc = iframe.document; if (iframe.contentDocument) { doc = iframe.contentDocument; } doc.open(); doc.writeln(html); doc.close(); doc.getElementById('myform').submit(); }; function handle3DSResponse(evt) { window.location.href = '\(Constants.sdkScheme)://secure3d?result=' + encodeURIComponent(evt.data); } window.addEventListener("message", handle3DSResponse, false); </script>
        </head>
        <body style="margin: 0;">
        <iframe id="iframe" style="display:block; border:none; width:100vw; height:100vh;"></iframe>
        </body>
        </html>
        """
    }
}

extension ThreeDS1WebViewController {
    func lazyActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }
    
    func lazyActivityBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: activityIndicator)
    }
    
    func lazyWebView() -> WKWebView {
        let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        return wv
    }
    
    func lazyCancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        return item
    }
    
    func lazyStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    func lazyNavigationBar() -> UINavigationBar {
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }
}
