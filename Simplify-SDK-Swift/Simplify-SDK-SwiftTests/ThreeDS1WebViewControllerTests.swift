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

import XCTest
import WebKit
@testable import Simplify

class ThreeDS1WebViewControllerTests: XCTestCase {

    let testSubject = ThreeDS1WebViewController(nibName: nil, bundle: nil)
    let navigationController = UINavigationController(nibName: nil, bundle: nil)
    
    var webView = WebViewSpy()
    var delegate = MockThreeDS1WebViewControllerDelegate()
    
    var cardToken = SimplifyMap()
    
    override func setUp() {
        cardToken.card.secure3DData.acsUrl.value = "http://stub.acs"
        cardToken.card.secure3DData.paReq.value = "stub.paReq"
        cardToken.card.secure3DData.md.value = "stub.md"
        cardToken.card.secure3DData.termUrl.value = "http://stub.term.url"
        testSubject.webView = webView
        testSubject.delegate = delegate
    }

    override func tearDown() {
    }
    
    func testAuthenticate_whenMissingAcsURL_throw() {
        cardToken.card.secure3DData.acsUrl.value = nil
        
        XCTassertThrowsError(try testSubject.authenticate(with: cardToken), equalTo: SimplifyError("Card token must contain 'card.secure3DData.acsUrl'"))
    }
    
    func testAuthenticate_whenMissingPaReq_throw() {
        cardToken.card.secure3DData.paReq.value = nil
        
        XCTassertThrowsError(try testSubject.authenticate(with: cardToken), equalTo: SimplifyError("Card token must contain 'card.secure3DData.paReq'"))
    }
    
    func testAuthenticate_whenMissingMd_throw() {
        cardToken.card.secure3DData.md.value = nil
        
        XCTassertThrowsError(try testSubject.authenticate(with: cardToken), equalTo: SimplifyError("Card token must contain 'card.secure3DData.md'"))
    }
    
    func testAuthenticate_whenMissingTermURL_throw() {
        cardToken.card.secure3DData.termUrl.value = nil
        
        XCTassertThrowsError(try testSubject.authenticate(with: cardToken), equalTo: SimplifyError("Card token must contain 'card.secure3DData.termUrl'"))
    }

    func testOnAuthenticate_WebViewLoadsHTML() {
        XCTAssertNoThrow(try testSubject.authenticate(with: cardToken))
        XCTAssertEqual(webView.loadHTMLStringCalls.count, 1)
        let load = webView.loadHTMLStringCalls.first!
        XCTAssertNil(load.baseURL)
        XCTAssertEqual(load.html, """
            <!DOCTYPE html>
            <html lang="en" dir="ltr">
            <head><meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
            <script> window.onload = function() { var html = '<form id="myform" method="post" enctype="application/x-www-form-urlencoded" action="http://stub.acs" >' + '<input type="hidden" name="PaReq" value="stub.paReq" />' + '<input type="hidden" name="MD" value="stub.md" />' + '<input type="hidden" name="TermUrl" value="http://stub.term.url" />' + '</form>'; var iframe = document.getElementById('iframe'); var doc = iframe.document; if (iframe.contentDocument) { doc = iframe.contentDocument; } doc.open(); doc.writeln(html); doc.close(); doc.getElementById('myform').submit(); }; function handle3DSResponse(evt) { window.location.href = 'simplifysdk://secure3d?result=' + encodeURIComponent(evt.data); } window.addEventListener("message", handle3DSResponse, false); </script>
            </head>
            <body style="margin: 0;">
            <iframe id="iframe" style="display:block; border:none; width:100vw; height:100vh;"></iframe>
            </body>
            </html>
            """)
    }
    
    func testWhenCancelled_delegateCancelled() {
        testSubject.cancel()
        XCTAssertTrue(delegate.didCancel)
    }
    
    
    func testWhenRedirectedToCompletionScheme_resultParsed_delegateNotified() {
        let action = StubWKNavigationAction(scheme: "simplifysdk", path: "secure3d", query: [URLQueryItem(name: "result", value: "{\"secure3d\":{\"authenticated\":true}}")])
        testSubject.webView(WKWebView(), decidePolicyFor: action) { _ in  }
        XCTAssertEqual(delegate.receivedACSAuthResult, true)
    }
    
    func testWhenReditedtedToOtherSchemes_delegateNotNotified() {
        let action = StubWKNavigationAction("https://secure3d")
        testSubject.webView(WKWebView(), decidePolicyFor: action) { _ in  }
        XCTAssertNil(delegate.receivedACSAuthResult)
    }
    
    func testWhenReditedtedToOtherSchemes_handlerAllow() {
        let action = StubWKNavigationAction("https://secure3d?result=achieved")
        var policy: WKNavigationActionPolicy? = nil
        testSubject.webView(WKWebView(), decidePolicyFor: action) { policy = $0 }
        XCTAssertEqual(policy, .allow)
    }
    
    func testWhenReditedtedToCompletionScheme_handlerCancel() {
        let action = StubWKNavigationAction("simplifysdk://secure3d?result=achieved")
        var policy: WKNavigationActionPolicy? = nil
        testSubject.webView(WKWebView(), decidePolicyFor: action) { policy = $0 }
        XCTAssertEqual(policy, .cancel)
    }
    
    func testWhenRedirectedToCompletionScheme_resultErrorParsed_delegateNotified() {
        let action = StubWKNavigationAction(scheme: "simplifysdk", path: "secure3d", query: [URLQueryItem(name: "result", value: "{\"secure3d\":{\"error\":\"something bad\"}}")])
        testSubject.webView(WKWebView(), decidePolicyFor: action) { _ in  }
        XCTAssertEqual(delegate.receivedError, "something bad")
    }
    
}


class MockThreeDS1WebViewControllerDelegate: ThreeDS1WebViewControllerDelegate {
    var receivedACSAuthResult: Bool? = nil
    var receivedCardToken: SimplifyMap? = nil
    func threeDS1WebViewController(_ threeDSView: ThreeDS1WebViewController, didReceiveACSAuthResult authenticated: Bool, for cardToken: SimplifyMap) {
        receivedACSAuthResult = authenticated
        receivedCardToken = cardToken
    }
    
    var receivedError: String? = nil
    func threeDS1WebViewController(_ webView: ThreeDS1WebViewController, didError error: String, for cardToken: SimplifyMap) {
        receivedError = error
        receivedCardToken = cardToken
    }
    
    var didCancel: Bool = false
    func threeDS1WebViewControllerDidCancel(_ webView: ThreeDS1WebViewController) {
        didCancel = true
    }
}

class StubWKNavigationAction: WKNavigationAction {
    var _request: URLRequest
    
    override var request: URLRequest {
        return _request
    }
    
    init(_ request: URLRequest) {
        _request = request
    }
    
    init(_ urlString: String) {
        _request = URLRequest(url: URL(string: urlString)!)
    }
    
    init(scheme: String, host: String? = nil, path: String, query: [URLQueryItem] = []) {
        var comp = URLComponents()
        comp.scheme = scheme
        comp.host = host
        comp.path = path
        comp.queryItems = query
        _request = URLRequest(url: comp.url!)
    }
}
