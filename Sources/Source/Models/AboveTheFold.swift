//
//  AboveTheFold.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation

struct AboveTheFold: Codable {
    let payload: Payload
    
    struct Payload: Codable {
        let mainHouseInfo: MainHouseInfo
        
        struct MainHouseInfo: Codable {
            let propertyAddress: PropertyAddress
            let selectedAmenities: [SelectedAmenities]
            
            struct PropertyAddress: Codable {
                let streetNumber: String
            }
            
            struct SelectedAmenities: Codable {
                let header: String
                let content: String
            }
        }
    }
}
