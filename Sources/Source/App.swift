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
        let propertyQuestion = "OPTIONAL: Enter the property ID (A number you need to find in Charles) or enter blank if you want to skip"
        var propertyID = Console.getInput(from: propertyQuestion, styled: .blue)
        
        if !propertyID.isEmpty {
            while Int(propertyID) == nil {
                if propertyID.isEmpty {
                    break
                }
                Console.writeMessage("Not a valid Number", styled: .red)
                propertyID = Console.getInput(from: propertyQuestion, styled: .blue)
            }
        }
        
        // MARK: - Hit Redfin Endpoint
        var houseData: HouseData?
        
        let runner = SwiftScriptRunner()
        runner.lock()
        
        getHouseData { data in
            houseData = data
            runner.unlock()
        }
        
        runner.wait()
        
        // MARK: - Store into CSV
        let workingDirectory = FileManager.default.currentDirectoryPath
        let csvFilePath = workingDirectory + "/homeData.csv"
        
        let csvFileURL = URL(fileURLWithPath: csvFilePath)
        
        let publicRecordsInfo = houseData?.belowTheFoldData?.payload.publicRecordsInfo
        
        let streetAddress = publicRecordsInfo?.addressInfo.street ?? ""
        
        let listingPrice = houseData?.belowTheFoldData?.payload.propertyHistoryInfo.events.first?.price ?? 0
        
        let yearBuilt = publicRecordsInfo?.basicInfo.yearBuilt ?? 0
        
        let lotSize = self.lotSize(from: houseData?.aboveTheFoldData, belowTheFold: houseData?.belowTheFoldData)
        
        let sqft = publicRecordsInfo?.basicInfo.totalSqFt ?? 0
        
        let stories = self.stories(from: houseData?.aboveTheFoldData)
        
        let bedCount = publicRecordsInfo?.basicInfo.beds ?? 0
        let bathCount = publicRecordsInfo?.basicInfo.baths ?? 0
        
        do {
            let stringConvertibleArray: [CustomStringConvertible] = [streetAddress, listingPrice, yearBuilt, lotSize, sqft, stories, bedCount, bathCount]

            try CSVWriter.addNewColumns(stringConvertibleArray, to: csvFileURL)
        } catch {
            print(error)
        }
    }
    
    private func getHouseData(completion: @escaping (HouseData) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        var aboveTheFold: AboveTheFold?
        var belowTheFold: BelowTheFold?
        
        dispatchGroup.enter()
        NetworkRequest.callAboveTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/aboveTheFold",
            propertyID: "6390569",
            listingID: "",
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
            propertyID: "6390569",
            listingID: "",
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
