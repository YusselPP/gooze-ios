//
//  GZEDateRequestApiRepository.swift
//  Gooze
//
//  Created by Yussel on 3/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss
import Alamofire


class GZEDateRequestApiRepository: GZEDateRequestRepositoryProtocol {

    init() {
        log.debug("\(self) init")
    }

    func findSentRequests(closed: Bool) -> SignalProducer<[GZEDateRequest], GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("findSentRequests SignalProducer disposed")
            }

            log.debug("trying to findSentRequests")

            let params =
                [
                    "filter": [
                        "where": [
                            "senderClosed": closed,
                            "senderId": userId
                        ],
                        "order": "createdAt DESC"
                    ]
                ] as [String : Any]
            Alamofire.request(GZEDateRequestRouter.find(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: [GZEDateRequest].from))
        }
    }

    func findReceivedRequests(closed: Bool) -> SignalProducer<[GZEDateRequest], GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("findReceivedRequests SignalProducer disposed")
            }

            log.debug("trying to findReceivedRequests")

            let params =
                [
                    "filter": [
                        "where": [
                            "recipientClosed": closed,
                            "recipientId": userId
                        ],
                         "order": "createdAt DESC"
                    ]
                ] as [String : Any]
            Alamofire.request(GZEDateRequestRouter.find(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: [GZEDateRequest].from))
        }
    }

    func findUnresponded() -> SignalProducer<[GZEDateRequest], GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<[GZEDateRequest], GZEError> { sink, disposable in

            disposable.add {
                log.debug("findUnresponded SignalProducer disposed")
            }

            log.debug("trying to find user unresponded date requests")

            let params: JSON = ["userId": userId]
            Alamofire.request(GZEDateRequestRouter.findUnresponded(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { jsonArray in

                    return [GZEDateRequest].from(jsonArray: jsonArray)
                }))
        }
    }

    func findActiveDate(by: String) -> SignalProducer<[GZEDateRequest], GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<[GZEDateRequest], GZEError> { sink, disposable in

            disposable.add {
                log.debug("findActiveDate SignalProducer disposed")
            }

            log.debug("trying to find user active date")

            let params =
                [
                    "filter": [
                        "where": [
                            "status": GZEDateRequest.Status.onDate.rawValue,
                            by: userId
                        ]
                    ]
                    ] as [String : Any]
            Alamofire.request(GZEDateRequestRouter.find(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { jsonArray in

                    return [GZEDateRequest].from(jsonArray: jsonArray)
                }))
        }
    }

    func startDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        guard let dateRequestJson = dateRequest.toJSON() else {
            log.error("Unnable to parse dateRequest to JSON")
            return SignalProducer(error: .repository(error: .UnexpectedError))
        }

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("startDate SignalProducer disposed")
            }

            log.debug("starting date...")

            Alamofire.request(GZEDateRequestRouter.startDate(json: dateRequestJson))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEDateRequest.init))
        }
    }

    func endDate(_ dateRequest: GZEDateRequest) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        guard let dateRequestJson = dateRequest.toJSON() else {
            log.error("Unnable to parse dateRequest to JSON")
            return SignalProducer(error: .repository(error: .UnexpectedError))
        }

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("endDate SignalProducer disposed")
            }

            log.debug("ending date...")

            Alamofire.request(GZEDateRequestRouter.endDate(json: dateRequestJson))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) -> (GZEDateRequest, GZEUser)? in

                    guard let dateJson = json["dateRequest"] as? JSON, let dateRequest = GZEDateRequest(json: dateJson) else {
                        return nil
                    }

                    guard let userJson = json["user"] as? JSON, let user = GZEUser(json: userJson) else {
                        return nil
                    }

                    return (dateRequest, user)
                }))
        }
    }

    func cancelDate(_ dateRequest: GZEDateRequest) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        guard let dateRequestJson = dateRequest.toJSON() else {
            log.error("Unnable to parse dateRequest to JSON")
            return SignalProducer(error: .repository(error: .UnexpectedError))
        }

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("cancelDate SignalProducer disposed")
            }

            log.debug("canceling date...")

            Alamofire.request(GZEDateRequestRouter.cancelDate(json: dateRequestJson))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) -> (GZEDateRequest, GZEUser)? in

                    guard let dateJson = json["dateRequest"] as? JSON, let dateRequest = GZEDateRequest(json: dateJson) else {
                        return nil
                    }

                    guard let userJson = json["user"] as? JSON, let user = GZEUser(json: userJson) else {
                        return nil
                    }

                    return (dateRequest, user)
                }))
        }
    }

    func close(_ dateRequest: GZEDateRequest, mode: GZEChatViewMode) -> SignalProducer<GZEDateRequest, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        guard let dateRequestJson = dateRequest.toJSON() else {
            log.error("Unnable to parse dateRequest to JSON")
            return SignalProducer(error: .repository(error: .UnexpectedError))
        }
        

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("close SignalProducer disposed")
            }

            log.debug("closing date...")

            Alamofire.request(GZEDateRequestRouter.closeChat(parameters: ["dateRequest": dateRequestJson, "mode": mode.rawValue]))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEDateRequest.init))
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
