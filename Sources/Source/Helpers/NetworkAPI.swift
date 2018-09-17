//
//  ANetworkRequest.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation
import MiniNe

struct NetworkAPI {
    
    static let jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()
    
    static func callAboveTheFold(propertyID: String,
                                 listingID: String,
                                 completion: @escaping (Result<AboveTheFold, NetworkAPIError>) -> Void) {
        
        let parameters: [String: Any] = ["accessLevel": "3",
                                         "propertyId": propertyID,
                                         "listingId": listingID]
        
        let request = AboveTheFoldNetworkRequest(parameters: parameters)
        
        let client = MiniNeClient()
        
        client.send(request: request) { (result) in
            switch result {
            case .success(let value):
                
                guard let data = validJSONData(from: value.data) else {
                    completion(Result(error: .dataConversionError))
                    return
                }
                
                do {
                    let result = try NetworkAPI.jsonDecoder.decode(AboveTheFold.self,
                                                                   from: data)
                    completion(Result(value: result))
                } catch {
                    completion(Result(error: .jsonDeserializingError(error)))
                }
            case .failure(let error):
                completion(Result(error: .networkRequestError(error)))
            }
        }
    }
    
    static func callBelowTheFold(propertyID: String,
                                 listingID: String,
                                 completion: @escaping (Result<BelowTheFold, NetworkAPIError>) -> Void) {
        
        let parameters: [String: Any] = ["accessLevel": "3",
                                         "propertyId": propertyID,
                                         "listingId": listingID]
        
        let request = BelowTheFoldNetworkRequest(parameters: parameters)
        
        let client = MiniNeClient()
        
        client.send(request: request) { (result) in
            switch result {
            case .success(let value):
                
                guard let data = validJSONData(from: value.data) else {
                    completion(Result(error: .dataConversionError))
                    return
                }
                
                do {
                    let result = try NetworkAPI.jsonDecoder.decode(BelowTheFold.self,
                                                                   from: data)
                    completion(Result(value: result))
                } catch {
                    completion(Result(error: .jsonDeserializingError(error)))
                }
            case .failure(let error):
                completion(Result(error: .networkRequestError(error)))
            }
        }
    }
}

// MARK: - Network API Error
extension NetworkAPI {
    enum NetworkAPIError: Error {
        case invalidURL
        case jsonDeserializingError(Error)
        case networkRequestError(Error)
        case dataConversionError
        case unknown
    }
}

// MARK: - Network Requests
extension NetworkAPI {
    struct AboveTheFoldNetworkRequest: NetworkRequest {
        var baseURL: URL? {
            return URL(string: "https://www.redfin.com")
        }
        
        var path: String {
            return "/stingray/mobile/api/v1/home/details/aboveTheFold"
        }
        
        var method: HTTPMethod {
            return .get
        }
        
        let parameters: [String : Any]?
        
        var headers: [String : Any]? {
            return nil
        }
    }
    
    struct BelowTheFoldNetworkRequest: NetworkRequest {
        var baseURL: URL? {
            return URL(string: "https://www.redfin.com")
        }
        
        var path: String {
            return "/stingray/mobile/api/v1/home/details/belowTheFold"
        }
        
        var method: HTTPMethod {
            return .get
        }
        
        let parameters: [String : Any]?
        
        var headers: [String : Any]? {
            return nil
        }
    }
}

// MARK: - Private Helpers
extension NetworkAPI {
    private static func validJSONData(from data: Data) -> Data? {
        guard data.count > 0,
            let stringData = String(data: data, encoding: .utf8) else {
                return nil
        }
        
        let validString = stringData.replacingOccurrences(of: "{}&&", with: "")
        
        guard let validData = validString.data(using: .utf8) else {
            return nil
        }
        
        return validData
    }
}
