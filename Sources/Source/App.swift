//
//  App.swift
//  Source
//
//  Created by Kevin Chen on 6/26/18.

import Foundation

// TODO: - Potentially parse out the map protobuf info, then I can get the listing ID by mapping against the property ID. See URL https://www.redfin.com/stingray/mobile/v2/gis-proto-mobile. It seems like I would need to input some info like coordinates and some filters into this URL.
// TODO: - Determine days on market before pending and sold
// TODO: - Repeat until exit
public class App {
    
    public init () {}
    
    public func start() {

        // MARK: - Get Listing ID
        let propertyQuestion = "Enter the property ID (The number in the URL)"
        var propertyID = Console.getInput(from: propertyQuestion, styled: .blue)
        
        while Int(propertyID) == nil {
            Console.writeMessage("Not a valid Number", styled: .red)
            propertyID = Console.getInput(from: propertyQuestion, styled: .blue)
        }
        
        // MARK: - Get Property ID
        let listingQuestion = "OPTIONAL: Enter the listing ID (A number you need to find in Charles) or enter blank if you want to skip"
        var listingID = Console.getInput(from: listingQuestion, styled: .blue)
        
        if !listingID.isEmpty {
            while Int(listingID) == nil {
                if listingID.isEmpty {
                    break
                }
                Console.writeMessage("Not a valid Number", styled: .red)
                listingID = Console.getInput(from: listingQuestion, styled: .blue)
            }
        }
        
        // MARK: - Hit Redfin Endpoint
        let houseData = HouseData()
        Console.writeMessage("**Fetching House Data")
        let runner = SwiftScriptRunner()
        runner.lock()
        
        houseData.fetchData(propertyID: propertyID, listingID: listingID) { errors in
            runner.unlock()
            if let errors = errors {
                errors.forEach({ (error) in
                    Console.writeMessage(error)
                    exit(1)
                })
            }
        }
        
        runner.wait()
        
        // MARK: - Store into CSV
        Console.writeMessage("**Store into CSV file")
        let workingDirectory = FileManager.default.currentDirectoryPath
        let csvFilePath = workingDirectory + "/homeData.csv"
        
        let csvFileURL = URL(fileURLWithPath: csvFilePath)
        
        guard let belowTheFoldData = houseData.belowTheFoldData,
            let _ = houseData.aboveTheFoldData else {
                Console.writeMessage("Missing Data", styled: .red)
                return
        }
         
        let publicRecordsInfo = belowTheFoldData.payload.publicRecordsInfo
        
        let streetAddress = publicRecordsInfo.addressInfo.street
        
        let latestEvent = belowTheFoldData.payload.propertyHistoryInfo.events.first
        let urlString = "https://www.redfin.com" + (latestEvent?.url ??  "")
        let eventType = latestEvent?.eventType ?? .unknown
        let eventDateString = latestEvent?.eventDateString ?? ""
        let listingPrice = latestEvent?.price ?? 0
        
        let yearBuilt = publicRecordsInfo.basicInfo.yearBuilt
        
        let lotSize = houseData.lotSize()
        
        let sqft = publicRecordsInfo.basicInfo.totalSqFt
        
        let stories = houseData.stories()
        
        let bedCount = publicRecordsInfo.basicInfo.beds
        let bathCount = publicRecordsInfo.basicInfo.baths
        
        do {
            let stringConvertibleArray: [CustomStringConvertible] = [streetAddress, eventType, eventDateString, urlString, listingPrice, yearBuilt, lotSize, sqft, stories, bedCount, bathCount]

            try CSVWriter.addNewColumns(stringConvertibleArray, to: csvFileURL)
            
            Console.writeMessage("**Finished!", styled: .green)
        } catch {
            Console.writeMessage(error)
        }
    }
}
