//
//  GZEStorageApiRepository.swift
//  Gooze
//
//  Created by Yussel on 11/7/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import Gloss

class GZEStorageApiRepository {

    init() {
        log.debug("\(self) init")
    }

    func uploadFiles(_ files: [Data?]) -> SignalProducer<GZEFile, GZEError> {
        return SignalProducer<GZEFile, GZEError> { [weak self] sink, disposable in

//            guard let this = self else {
//                log.error("Unable to complete the task. Self has been disposed.")
//                sink.send(error: .UnexpectedError)
//                sink.sendInterrupted()
//                return
//            }

            disposable.add {
                log.debug("signUp SignalProducer disposed")
            }

            Alamofire.upload(multipartFormData: { multipartFormData in
                for file in files {
                    if file != nil {
                        multipartFormData.append(file!, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                    }
                }
//                for (key, value) in parameters {
//                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//                }
            }, to: GZEAppConfig.goozeApiUrl + "/containers/picture/upload?access_token=\(GZEApi.instance.accessToken!.id)",

            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        log.debug(response)
                        sink.send(value: GZEFile(json: response.result.value as! JSON)!)
                        sink.sendCompleted()
                    }
                case .failure(let error):
                    log.error(error)
                    sink.send(error: .repository(error: .UnexpectedError))
                    sink.sendCompleted()
                }
            })

        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
