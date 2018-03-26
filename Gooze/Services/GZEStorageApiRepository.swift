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

    func uploadFiles(_ files: [GZEFile], container: String) -> SignalProducer<[GZEFile], GZEError> {
        return SignalProducer<[GZEFile], GZEError> { sink, disposable in

            disposable.add {
                log.debug("uploadFiles SignalProducer disposed")
            }

            guard let token = GZEApi.instance.accessToken?.id else {
                sink.send(error: .repository(error: .AuthRequired))
                sink.sendInterrupted()
                return
            }

            Alamofire.upload(multipartFormData: { multipartFormData in
                for file in files {
                    if let data = file.data {
                        log.debug(data.count)
                        // multipartFormData.append(data, withName: "files", fileName: file?.name ?? "file", mimeType: file?.type ?? "image/jpeg")
                        multipartFormData.append(data, withName: file.name, fileName: file.name, mimeType: file.type)
                    }
                }
//                for (key, value) in parameters {
//                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//                }
            },
            to: GZEAppConfig.goozeApiUrl + "/containers/\(container)/upload",

            headers: [ "Authorization": token],

            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) in

                        if let responseFiles = GZEApiStorageResponse(json: json)?.files {

                            for file in files {
                                if let name = responseFiles[file.name]??.name {
                                    file.name = name
                                    file.persisted = true
                                }
                            }
                        }

                        return files
                    }))
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
