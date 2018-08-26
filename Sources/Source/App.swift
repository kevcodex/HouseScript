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
        var aHouseData: HouseData?
        
        let runner = SwiftScriptRunner()
        runner.lock()
        
        getHouseData(propertyID: propertyID, listingID: listingID) { data in
            aHouseData = data
            runner.unlock()
        }
        
        runner.wait()
        
        // MARK: - Store into CSV
        let workingDirectory = FileManager.default.currentDirectoryPath
        let csvFilePath = workingDirectory + "/homeData.csv"
        
        let csvFileURL = URL(fileURLWithPath: csvFilePath)
        
        guard let houseData = aHouseData,
            let belowTheFoldData = houseData.belowTheFoldData,
            let aboveTheFoldData = houseData.aboveTheFoldData else {
                Console.writeMessage("Missing Data", styled: .red)
                return
        }
         
        let publicRecordsInfo = belowTheFoldData.payload.publicRecordsInfo
        
        let streetAddress = publicRecordsInfo.addressInfo.street
        
        let listingPrice = belowTheFoldData.payload.propertyHistoryInfo.events.first?.price ?? 0
        
        let yearBuilt = publicRecordsInfo.basicInfo.yearBuilt
        
        let lotSize = self.lotSize(from: aboveTheFoldData, belowTheFold: belowTheFoldData)
        
        let sqft = publicRecordsInfo.basicInfo.totalSqFt
        
        let stories = self.stories(from: aboveTheFoldData)
        
        let bedCount = publicRecordsInfo.basicInfo.beds
        let bathCount = publicRecordsInfo.basicInfo.baths
        
        do {
            let stringConvertibleArray: [CustomStringConvertible] = [streetAddress, listingPrice, yearBuilt, lotSize, sqft, stories, bedCount, bathCount]

            try CSVWriter.addNewColumns(stringConvertibleArray, to: csvFileURL)
        } catch {
            print(error)
        }
    }
    
    /// - parameter propertyID: **Required**. You can find this at the end of the house URL. E.g. https://www.redfin.com/CA/Encinitas/1943-Village-Wood-Rd-92024/home/**6390569**
    /// - parameter listingID: ListingID does not require to have a value. I'm not sure where this value is taken from but You can find it in the param request in Charles. It just adds a bit more info if you include it.
    private func getHouseData(propertyID: String, listingID: String, completion: @escaping (HouseData) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        var aboveTheFold: AboveTheFold?
        var belowTheFold: BelowTheFold?
        
        dispatchGroup.enter()
        NetworkRequest.callAboveTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/aboveTheFold",
            propertyID: propertyID,
            listingID: listingID,
            completion: { result in
                switch result {
                    
                case .success(let response):
                    aboveTheFold = response
                case .failure(let error):
                    Console.writeMessage(error.localizedDescription, styled: .red)
                }
                dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        NetworkRequest.callBelowTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/belowTheFold",
            propertyID: propertyID,
            listingID: listingID,
            completion: { result in
                switch result {
                    
                case .success(let response):
                    belowTheFold = response
                case .failure(let error):
                    Console.writeMessage(error.localizedDescription, styled: .red)
                }
                
                dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            let houseData = HouseData(aboveTheFoldData: aboveTheFold, belowTheFoldData: belowTheFold)
            completion(houseData)
        }
    }
    
    private func lotSize(from aboveTheFold: AboveTheFold?, belowTheFold: BelowTheFold?) -> Int {
        guard let aboveTheFold = aboveTheFold,
            let belowTheFold = belowTheFold else {
                return 0
        }
        
        var lotSize = belowTheFold.payload.publicRecordsInfo.basicInfo.lotSqFt
        
        if lotSize != 0 {
            return lotSize
        }
        
        for admentities in aboveTheFold.payload.mainHouseInfo.selectedAmenities {
            if admentities.header == "Lot Size" {
                let lotSizeString = admentities.content.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
                lotSize = Int(lotSizeString) ?? 0
            }
        }
        
        return lotSize
    }
    
    private func stories(from aboveTheFold: AboveTheFold?) -> String {
        guard let aboveTheFold = aboveTheFold else {
            return ""
        }
        
        for admentities in aboveTheFold.payload.mainHouseInfo.selectedAmenities {
            if admentities.header == "Stories" {
                return admentities.content
            }
        }
        
        return ""
    }
}
