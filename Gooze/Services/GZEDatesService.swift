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

    func requestDate(to userId: String) {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return
        }

        log.debug("sending date request...")
        dateSocket.emitWithAck(.dateRequestSent, userId).timingOut(after: 5) {[weak self] data in
            log.debug("ack data: \(data)")
            
            if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                log.error("No ack received from server")
                return
            }
            
            if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                
                if error.code == DatesSocketError.requestAlreadySent.rawValue {
                    log.debug("Request already sent")
                    self?.errorMessage.value = DatesSocketError.requestAlreadySent.localizedDescription
                } else {
                    log.error("\(String(describing: error.toJSON()))")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                }
                
            } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                
                //TODO: insert at begining to give instant feedback to user, maybe this method should receive dateRequets
                GZEDatesService.shared.sentRequests.value.append(dateRequest)
                self?.message.value = "service.dates.requestSuccessfullySent".localized()
                log.debug("Date request successfully sent")
                
            } else {
                log.error("Unable to parse data to expected objects")
                self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            }
        }
    }
    
    func acceptDateRequest(from userId: String) {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return
        }
        
        log.debug("emitting accept request...")
        dateSocket.emitWithAck(.acceptRequest, userId).timingOut(after: 5) {[weak self] data in
            log.debug("ack data: \(data)")
            
            if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                log.error("No ack received from server")
                return
            }
            
            if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                
//                if error.code == DatesSocketError.requestAlreadySent.rawValue {
//                    log.debug("Request already sent")
//                    self?.errorMessage.value = DatesSocketError.requestAlreadySent.localizedDescription
//                } else {
                    log.error("\(String(describing: error.toJSON()))")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
//                }
                
            } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                
                GZEDatesService.shared.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
                // self?.message.value = "service.dates.requestSuccessfullyAccepted".localized()
                log.debug("Date request successfully accepted")
                
            } else {
                log.error("Unable to parse data to expected objects")
                self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            }
        }
    }
}
