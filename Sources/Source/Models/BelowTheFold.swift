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
        
        struct PublicRecordInfo: Codable {
            let basicInfo: BasicInfo
            let mortgageCalculatorInfo: MortgageCalculatorInfo
            
            struct BasicInfo: Codable {
                let beds: Int
                let baths: Int
                let yearBuilt: Int
                let sqFtFinished: Int
                let totalSqFt: Int
                let lotSqFt: Int
            }
            
            struct MortgageCalculatorInfo: Codable {
                let listingPrice: Int
            }
        }
    }
}
