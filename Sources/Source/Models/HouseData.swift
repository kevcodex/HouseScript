//
//  HouseData.swift
//  HouseSearchScript
//
//  Created by Kirby on 8/25/18.
//

import Foundation

class HouseData {
    private(set) var aboveTheFoldData: AboveTheFold?
    private(set) var belowTheFoldData: BelowTheFold?
    
    init() {
        aboveTheFoldData = nil
        belowTheFoldData = nil
    }
}

// MARK: - Fetch
extension HouseData {
    
    /// - parameter propertyID: **Required**. You can find this at the end of the house URL. E.g. https://www.redfin.com/CA/Encinitas/1943-Village-Wood-Rd-92024/home/**6390569**
    /// - parameter listingID: ListingID does not require to have a value. This values comes from the protobuf of the map. URL is https://www.redfin.com/stingray/mobile/v2/gis-proto-mobile. You can find it in the param request in Charles. It just adds a bit more info if you include it.
    func fetchData(propertyID: String, listingID: String, completion: @escaping ([Error]?) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        var errors: [Error] = []
        
        dispatchGroup.enter()
        NetworkRequest.callAboveTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/aboveTheFold",
            propertyID: propertyID,
            listingID: listingID,
            completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    
                case .success(let response):
                    strongSelf.aboveTheFoldData = response
                case .failure(let error):
                    errors.append(error)
                }
                dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        NetworkRequest.callBelowTheFold(
            urlString: "https://www.redfin.com/stingray/mobile/api/v1/home/details/belowTheFold",
            propertyID: propertyID,
            listingID: listingID,
            completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    
                case .success(let response):
                    strongSelf.belowTheFoldData = response
                case .failure(let error):
                    errors.append(error)
                }
                
                dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            errors.isEmpty ? completion(nil) : completion(errors)
        }
    }
}

// MARK: - Helpers
extension HouseData {
    func lotSize() -> Int {
        guard let aboveTheFold = aboveTheFoldData,
            let belowTheFold = belowTheFoldData else {
                return 0
        }
        
        var lotSize = belowTheFold.payload.publicRecordsInfo.basicInfo.lotSqFt
        
        if lotSize != 0 {
            return lotSize
        }
        
        aboveTheFold.selectedAmenities?.forEach { admentities in
            if admentities.header == "Lot Size" {
                let lotSizeString = admentities.content.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted).replacingOccurrences(of: ",", with: "")
                
                lotSize = Int(lotSizeString) ?? 0
            }
        }
        
        return lotSize
    }
    
    func stories() -> String {
        guard let selectedAmenities = aboveTheFoldData?.selectedAmenities else {
            return ""
        }
        
        for admentities in selectedAmenities {
            if admentities.header == "Stories" {
                return admentities.content
            }
        }
        
        return ""
    }
}
