//
//  BelowTheFold.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation

struct BelowTheFold: Codable {
    let payload: Payload
    
    struct Payload: Codable {
        let publicRecordsInfo: PublicRecordInfo
        let propertyHistoryInfo: PropertyHistoryInfo
        
        struct PublicRecordInfo: Codable {
            let basicInfo: BasicInfo
            let addressInfo: AddressInfo
            let mortgageCalculatorInfo: MortgageCalculatorInfo?
            
            struct BasicInfo: Codable {
                let beds: Int
                let baths: Int
                let yearBuilt: Int
                let sqFtFinished: Int
                let totalSqFt: Int
                let lotSqFt: Int
            }
            
            struct AddressInfo: Codable {
                let street: String
                let city: String
                let state: String
                let zip: String
            }
            
            struct MortgageCalculatorInfo: Codable {
                let listingPrice: Int
            }
        }
        
        struct PropertyHistoryInfo: Codable {
            let events: [Event]

            struct Event: Codable {
                let price: Int?
                let url: String?
            }
        }
    }
}
