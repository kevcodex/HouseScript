//
//  App.swift
//  Source
//
//  Created by Kevin Chen on 6/26/18.

import Foundation

public class App {
    
    public init () {
        
    }
    
    public func start() {

        // MARK: - Get Listing ID
        let listingQuestion = "Enter the listing ID (The number in the URL)"
        var listingID = Console.getInput(from: listingQuestion, styled: .blue)
        
        while Int(listingID) == nil {
            Console.writeMessage("Not a valid Number", styled: .red)
            listingID = Console.getInput(from: listingQuestion, styled: .blue)
        }
        
        // MARK: - Get Property ID
        let propertyQuestion = "Enter the property ID (A number you need to find)"
        var propertyID = Console.getInput(from: propertyQuestion, styled: .blue)
        
        while Int(propertyID) == nil {
            Console.writeMessage("Not a valid Number", styled: .red)
            propertyID = Console.getInput(from: propertyQuestion, styled: .blue)
        }

        // MARK: - Hit Redfin Endpoint
        let runner = SwiftScriptRunner()
        runner.lock()
        
        getHouseData {
            runner.unlock()
        }
        
        
        runner.wait()
        
        // MARK: - Store into CSV
    }
    
    private func getHouseData(completion: @escaping () -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        NetworkRequest.callAboveTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/aboveTheFold",
            listingID: "86275967",
            propertyID: "6390569",
            completion: { result in
                switch result {
                    
                case .success(let response):
                    print(response)
                case .failure(let error):
                    Console.writeMessage(error.localizedDescription, styled: .red)
                }
                dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        NetworkRequest.callBelowTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/belowTheFold",
            listingID: "86275967",
            propertyID: "6390569",
            completion: { result in
                switch result {
                    
                case .success(let response):
                    print(response)
                case .failure(let error):
                    Console.writeMessage(error.localizedDescription, styled: .red)
                }
                
                dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
