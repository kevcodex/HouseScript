//
//  ANetworkRequest.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation
import Alamofire

struct NetworkRequest {
    
    enum NetworkError: Error {
        case invalidURL
        case jsonDeserializingError(Error)
        case networkRequestError(Error)
        case unknown
    }
    
    static let jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()
    
    static func callAboveTheFold(urlString: String,
                                 listingID: String,
                                 propertyID: String,
                                 completion: @escaping (Result<AboveTheFold, NetworkError>) -> Void) {
        
        guard let urlRequest = constructURLRequest(urlString: urlString, listingID: listingID, propertyID: propertyID) else {
            completion(Result(error: .invalidURL))
            return
        }
        
        Alamofire.request(urlRequest).responseSpecializedJSON { (response) in
            switch response.result {
                
            case .success(let json):
                
                guard let jsonDictionary = json as? [String: Any] else {
                    completion(Result(error: .unknown))
                    return
                }
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
                    
                    let result = try NetworkRequest.jsonDecoder.decode(AboveTheFold.self,
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
    
    static func callBelowTheFold(urlString: String,
                                 listingID: String,
                                 propertyID: String,
                                 completion: @escaping (Result<BelowTheFold, NetworkError>) -> Void) {
        guard let urlRequest = constructURLRequest(urlString: urlString, listingID: listingID, propertyID: propertyID) else {
            completion(Result(error: .invalidURL))
            return
        }
        
        
        Alamofire.request(urlRequest).responseSpecializedJSON { (response) in
            switch response.result {
                
            case .success(let json):
                
                guard let jsonDictionary = json as? [String: Any] else {
                    completion(Result(error: .unknown))
                    return
                }
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
                    
                    let result = try NetworkRequest.jsonDecoder.decode(BelowTheFold.self,
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
    
    private static func constructURLRequest(urlString: String,
                                     listingID: String,
                                     propertyID: String) -> URLRequest? {
        
        let accessLevelQuery = URLQueryItem(name: "accessLevel", value: "3")
        let listingIDQuery = URLQueryItem(name: "listingId", value: listingID)
        let propertyIDQuery = URLQueryItem(name: "propertyId", value: propertyID)
        
        let queryItems = [accessLevelQuery, listingIDQuery, propertyIDQuery]
        
        var urlString = urlString
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems
        
        if let adjustedURLString = urlComponents?.url?.absoluteString {
            urlString = adjustedURLString
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
}

