//
//  PayPalService.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/10/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import Braintree
import BraintreeDropIn
import Gloss

class PayPalService: NSObject, BTViewControllerPresentingDelegate, BTAppSwitchDelegate {
    static let shared = PayPalService()
    static let deviceData = PPDataCollector.collectPayPalDeviceData()

    var presenter: UIViewController?
    var presenterCompletion: CompletionBlock?

    func fetchClientToken() -> SignalProducer<String, GZEError> {

        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            disposable.add {
                log.debug("fetchClientToken SignalProducer disposed")
            }

            log.debug("requesting client token")

            Alamofire.request(GZEPayPalRouter.clientToken)
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { $0 })
        }
    }

    func showDropIn(presenter: UIViewController) -> SignalProducer<BTDropInResult, GZEError> {

        return (
            self.fetchClientToken()
            .flatMap(.latest) {clientToken -> SignalProducer<BTDropInResult, GZEError> in
                return SignalProducer{sink, disposable in
                    let request =  BTDropInRequest()
                    let dropIn = BTDropInController(authorization: clientToken, request: request)
                    {(controller, result, error) in
                        if let error = error {
                            sink.send(error: .payment(error: .paypal(error)))
                        } else if (result?.isCancelled == true) {
                            log.debug("Cancelled")
                            sink.sendInterrupted()
                        } else if let result = result {
                            // Use the BTDropInResult properties to update your UI
                            // result.paymentOptionType
                            // result.paymentMethod
                            // result.paymentIcon
                            // result.paymentDescription
                            sink.send(value: result)
                            sink.sendCompleted()
                        }
                        controller.dismiss(animated: true, completion: nil)
                    }
                    presenter.present(dropIn!, animated: true, completion: nil)
                }
            }
        )

    }

    func charge(amount: Decimal, paymentMethodNonce: String, dateRequest: GZEDateRequest) -> SignalProducer<JSON, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            disposable.add {
                log.debug("charge SignalProducer disposed")
            }

            log.debug("charging")

            let parameters: Parameters = [
                "amount": amount.description,
                "paymentMethodNonce": paymentMethodNonce,
                "deviceData": PayPalService.deviceData,
                "description": "Recipient: \(dateRequest.recipient.username), DateRequest: \(dateRequest.id)",
                "dateRequestId": dateRequest.id,
                "fromUserId": dateRequest.sender.id,
                "toUserId": dateRequest.recipient.id
            ]

            Alamofire.request(GZEPayPalRouter.createCharge(parameters: parameters))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { $0 })
        }
    }

    func charge(amount: Decimal, paymentMethodToken: String, dateRequest: GZEDateRequest) -> SignalProducer<JSON, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            disposable.add {
                log.debug("charge SignalProducer disposed")
            }

            log.debug("charging")

            let parameters: Parameters = [
                "amount": amount.description,
                "paymentMethodToken": paymentMethodToken,
                "deviceData": PayPalService.deviceData,
                "description": "Recipient: \(dateRequest.recipient.username), DateRequest: \(dateRequest.id)",
                "dateRequestId": dateRequest.id,
                "fromUserId": dateRequest.sender.id,
                "toUserId": dateRequest.recipient.id
            ]

            Alamofire.request(GZEPayPalRouter.createCharge(parameters: parameters))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { $0 })
        }
    }

    func oneTimePaymentNonce(amount: Decimal, presenter: UIViewController, presentCompletion: CompletionBlock? = nil) -> SignalProducer<BTPayPalAccountNonce, GZEError> {

        self.presenter = presenter
        self.presenterCompletion = presentCompletion

        log.debug("requesting oneTimePayment")

        return (
            self.fetchClientToken()
                .flatMap(.latest) {clientToken -> SignalProducer<BTPayPalAccountNonce, GZEError> in

                    return SignalProducer{sink, disposable in

                        let braintreeClient = BTAPIClient(authorization: clientToken)!
                        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
                        payPalDriver.viewControllerPresentingDelegate = self
                        payPalDriver.appSwitchDelegate = self

                        let request = BTPayPalRequest(amount: amount.description)
                        request.displayName = "Gooze"
                        request.currencyCode = "MXN"

                        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) -> Void in
                            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                                log.debug(tokenizedPayPalAccount)
                                log.debug("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                                log.debug("Email: \(String(describing: tokenizedPayPalAccount.email))")
                                // Send payment method nonce to your server to create a transaction
                                sink.send(value: tokenizedPayPalAccount)
                                sink.sendCompleted()
                            } else if let error = error {
                                // Handle error here...
                                log.error(error.localizedDescription)
                                sink.send(error: .payment(error: .paypal(error)))
                            } else {
                                // Buyer canceled payment approval
                                log.debug("Canceled")
                                sink.sendInterrupted()
                            }
                        }
                    }
                }
        )
    }

    func requestBillingAgreement(presenter: UIViewController, clientToken: String, presentCompletion: CompletionBlock? = nil) -> SignalProducer<BTPayPalAccountNonce, GZEError> {
        self.presenter = presenter
        self.presenterCompletion = presentCompletion
        let braintreeClient = BTAPIClient(authorization: clientToken)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self


        log.debug("requesting billing agreement")

        let request = BTPayPalRequest()
        request.billingAgreementDescription = "Gooze payments" //Displayed in customer's PayPal account

        return SignalProducer{sink, disposable in
            payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
                if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                    log.debug("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                    log.debug("Email: \(String(describing: tokenizedPayPalAccount.email))")
                    // Send payment method nonce to your server to create a transaction
                    sink.send(value: tokenizedPayPalAccount)
                    sink.sendCompleted()
                } else if let error = error {
                    // Handle error here...
                    log.error(error.localizedDescription)
                    sink.send(error: .payment(error: .paypal(error)))
                } else {
                    // Buyer canceled payment approval
                    log.debug("Canceled")
                    sink.sendInterrupted()
                }
            }
        }
    }

    func createPaymentMethod(_ paymentMethodNonce: String) -> SignalProducer<JSON, GZEError> {
        guard let authUser = GZEAuthService.shared.authUser else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            disposable.add {
                log.debug("createPaymentMethod SignalProducer disposed")
            }

            log.debug("creating PaymentMethod")


            if let customerId = authUser.paypalCustomerId {
                let parameters: Parameters = [
                    "userId": authUser.id,
                    "paymentMethodNonce": paymentMethodNonce,
                    "customerId": customerId
                ]

                Alamofire.request(GZEPayPalRouter.createPaymentMethod(parameters: parameters))
                    .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { $0 })
            } else {
                let parameters: Parameters = [
                    "userId": authUser.id,
                    "paymentMethodNonce": paymentMethodNonce
                ]

                Alamofire.request(GZEPayPalRouter.createCustomer(parameters: parameters))
                    .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { $0 })
            }
        }
    }

    func savePaymentMethod(presenter: UIViewController, presentCompletion: CompletionBlock? = nil, completion: HandlerBlock<Bool>? = nil) {
        self.fetchClientToken()
            .flatMap(.latest) {[weak self] clientToken -> SignalProducer<BTPayPalAccountNonce, GZEError> in
                guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}
                return this.requestBillingAgreement(presenter: presenter, clientToken: clientToken, presentCompletion: presentCompletion)
            }
            .flatMap(.latest) {[weak self] tokenizedAccount -> SignalProducer<JSON, GZEError> in
                guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}
                return this.createPaymentMethod(tokenizedAccount.nonce)
            }
            .start{[weak self] in
                guard let this = self else {
                    log.error("Self was disposed")
                    completion?(false)
                    return
                }

                switch $0 {
                case .value(let response):
                    guard let response = response["response"] as? JSON, let success = response["success"] as? Bool else {
                        log.error("Invalid response received")
                        completion?(false)
                        return
                    }

                    if success {
                        if let customer = response["customer"] as? JSON {
                            GZEAuthService.shared.authUser?.paypalCustomerId = customer["id"] as? String
                        }
                        completion?(true)
                    } else {
                        log.error("Error: \(String(describing: response))")
                        if let message = response["message"] as? String {
                            GZEAlertService.shared.showBottomAlert(text: message)
                        }
                        completion?(false)
                    }

                case .failed(let error):
                    log.error(error)
                    this.onError(error)
                    completion?(false)
                case .interrupted:
                    completion?(false)
                case .completed:
                    break
                }
        }
    }

    func getPaymentMethods() -> SignalProducer<[GZEPayPalPaymentMethod], GZEError> {
        guard let authUser = GZEAuthService.shared.authUser else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        guard let customerId = authUser.paypalCustomerId else {
            return SignalProducer(value: [])
        }

        return SignalProducer{sink, disposable in

            disposable.add {
                log.debug("charge SignalProducer disposed")
            }

            log.debug("charging")

            Alamofire.request(GZEPayPalRouter.findPaymentMethods(customerId: customerId))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { [GZEPayPalPaymentMethod].from(jsonArray: $0) })
        }
    }

    func deletePayPalMethod(_ payPalMethod: GZEPayPalPaymentMethod) -> SignalProducer<JSON, GZEError> {
        guard GZEAuthService.shared.authUser != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            disposable.add {
                log.debug("deletePayPalMethod SignalProducer disposed")
            }

            log.debug("deleting PayPal method")

            Alamofire.request(GZEPayPalRouter.deletePaymentMethod(token: payPalMethod.token))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { $0 })
        }
    }

    func onError(_ error: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: error.localizedDescription)
    }

    // MARK: - BTViewControllerPresentingDelegate

    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        log.debug("presenting btvc")
        self.presenter?.present(viewController, animated: true, completion: self.presenterCompletion)
    }

    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - BTAppSwitchDelegate


    // Optional - display and hide loading indicator UI
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        showLoadingUI()

        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingUI), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        hideLoadingUI()
    }

    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {

    }

    // MARK: - Private methods

    func showLoadingUI() {
        // ...
    }

    @objc func hideLoadingUI() {
        NotificationCenter
            .default
            .removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        // ...
    }
}
