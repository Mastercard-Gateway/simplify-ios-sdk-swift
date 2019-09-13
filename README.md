# Simplify iOS SDK

The iOS SDK by Simplify allows you to create a card token (one time use token representing card details) in your iOS app to send to a server to enable it to make a payment. By creating a card token, Simplify allows you to avoid sending card details to your server. The SDK can help with formatting and validating card information before the information is tokenized.

## Requirements
  - Swift 5 or higher

## Installation

The iOS SDK can be manualy included in your project by downloading or cloning the SDK project and adding it as a subproject in your project.  


If you would like to use [Carthage]( https://github.com/Carthage/Carthage) to integrate the sdk into your project, you can do so with the following line in your cartfile.

```
github "simpliftcom/simplify-ios-sdk"
```

## Usage

## Import the SDK
Import the Simplify SDK into your project

```swift
import Simplify
```

## Initialialize the SDK
In order to use the SDK, you must initialize the `Simplify` object with your public api key.

```swift
let simplify = Simplify(apiKey: <#your public api key#>)
```
> Your public api key can be found and managed under "Account Settings" > "API Keys" on the Simplify website.

## Create a Card Token
Once you have inititalized an instance of `Simplify`, you can then construct a `SimplifyMap` containing the card information and pass that to the `createCardToken` function to create a card token.

```swift
var card = SimplifyMap()
card.number.value = "<#card number#>"
card.cvc.value = "<#security code#>"
card.expMonth.value = "<#expiration month#>"
card.expYear.value = "<#expiration year#>"

simplify.createCardToken(card: card) { (result) in
    switch (result) {
    case .success(let cardToken):
        // do provide the CardToken to your server to process the payment
    case .failure(let error):
        // handle the error
    }
}
```

---

## Sample App
This project includes a sample app to demonstrate SDK usage. To configure the sample app, add your public key to the `PaymentViewController` in the project.

