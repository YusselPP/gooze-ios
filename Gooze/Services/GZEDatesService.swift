//
//  GZEDatesService.swift
//  Gooze
//
//  Created by Yussel on 3/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss
import SocketIO
import ReactiveSwift

class GZEDatesService: NSObject {

    static let shared = GZEDatesService()

    let lastReceivedRequest = MutableProperty<GZEDateRequest?>(nil)
    let receivedRequests = MutableProperty<[GZEDateRequest]>([])
    
    let lastSentRequest = MutableProperty<GZEDateRequest?>(nil)
    let sentRequests = MutableProperty<[GZEDateRequest]>([])

    var dateSocket: DatesSocket? {
        return GZESocketManager.shared[DatesSocket.namespace] as? DatesSocket
    }
    
    var message = MutableProperty<String?>(nil)
    
    var errorMessage = MutableProperty<String?>(nil)

    override init() {
        super.init()
        receivedRequests.signal.observeValues {
            log.debug("receivedRequests changed: \(String(describing: $0.toJSONArray()))")
        }
        sentRequests.signal.observeValues {
            log.debug("sentRequests changed: \(String(describing: $0.toJSONArray()))")
        }
    }
    
    func findUnrespondedRequests() {
        GZEDateRequestApiRepository().findUnresponded().startWithSignal{[weak self] sink, disposable in
            sink.observe { event in
                log.debug("event received: \(event)")
                switch event {
                case .value(let dateRequests):
//                    for dateRequest in dateRequests {
//                        self?.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
//                    }
                    self?.receivedRequests.value = dateRequests
                default: break
                }
            }
        }
    }

    func requestDate(to recipientId: String) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        log.debug("sending date request...")
        return SignalProducer { sink, disposable in
            dateSocket.emitWithAck(.dateRequestSent, recipientId).timingOut(after: 5) {[weak self] data in
                log.debug("ack data: \(data)")
                
                disposable.add {
                    log.debug("acceptDateRequest signal disposed")
                }
                
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                    if error.code == DatesSocketError.requestAlreadySent.rawValue {
                        log.debug("Request already sent")
                        self?.errorMessage.value = DatesSocketError.requestAlreadySent.localizedDescription
                        sink.send(error: .datesSocket(error: .requestAlreadySent))
                    } else {
                        log.error("\(String(describing: error.toJSON()))")
                        self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                        sink.send(error: .datesSocket(error: .unexpected))
                    }
                    
                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                    
                    log.debug("Date request successfully sent")
                    self?.sentRequests.value.upsert(dateRequest){$0 == dateRequest}
                    self?.lastSentRequest.value = dateRequest
                    self?.message.value = "service.dates.requestSuccessfullySent".localized()
                    sink.send(value: dateRequest)
                    sink.sendCompleted()
                } else {
                    log.error("Unable to parse data to expected objects")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }
    
    func acceptDateRequest(withId requestId: String?) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        guard let requestId = requestId else {
            log.error("Request id is required to accept a request")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        return SignalProducer { sink, disposable in
            log.debug("emitting accept request...")
            dateSocket.emitWithAck(.acceptRequest, requestId).timingOut(after: 5) {[weak self] data in
                log.debug("ack data: \(data)")
                
                disposable.add {
                    log.debug("acceptDateRequest signal disposed")
                }
                
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                    if error.code == DatesSocketError.invalidSatus.rawValue {
                        log.debug("Request invalid status")
                        self?.errorMessage.value = DatesSocketError.invalidSatus.localizedDescription
                        sink.send(error: .datesSocket(error: .invalidSatus))
                    } else {
                        log.error("\(String(describing: error.toJSON()))")
                        self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                        sink.send(error: .datesSocket(error: .unexpected))
                    }
                    
                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                    
                    log.debug("Date request successfully accepted")
                    GZEDatesService.shared.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
                    GZEDatesService.shared.lastReceivedRequest.value = dateRequest
                    sink.send(value: dateRequest)
                    sink.sendCompleted()
                    
                } else {
                    log.error("Unable to parse data to expected objects")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }
}
