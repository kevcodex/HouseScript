//
//  Alamofire+Extensions.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Alamofire
import Foundation

extension DataRequest {
    @discardableResult
    func responseSpecializedJSON(queue: DispatchQueue? = nil,
                                 options: JSONSerialization.ReadingOptions = .allowFragments,
                                 completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {
        return response(
            queue: queue,
            responseSerializer: DataRequest.specializedJsonResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
    
    public static func specializedJsonResponseSerializer(
        options: JSONSerialization.ReadingOptions = .allowFragments)
        -> DataResponseSerializer<Any>
    {
        return DataResponseSerializer { _, response, data, error in
            return Request.specializedSerializeResponseJSON(options: options, response: response, data: data, error: error)
        }
    }
}

extension Request {
    public static func specializedSerializeResponseJSON(
        options: JSONSerialization.ReadingOptions,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> Alamofire.Result<Any>
    {
        guard error == nil else { return .failure(error!) }
        
        let emptyDataStatusCodes: Set<Int> = [204, 205]
        
        if let response = response, emptyDataStatusCodes.contains(response.statusCode) { return .success(NSNull()) }
        
        guard let data = data, data.count > 0,
            let stringData = String(data: data, encoding: .utf8)  else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }
        
        let validString = stringData.replacingOccurrences(of: "{}&&", with: "")
        
        guard let validData = validString.data(using: .utf8) else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: validData, options: options)
            return .success(json)
        } catch {
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
    }
}
