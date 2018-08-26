//
//  AboveTheFold.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation

// TODO: Clean
struct AboveTheFold: Codable {
    let payload: Payload
    
    struct Payload: Codable {
        let mainHouseInfo: MainHouseInfo
        
        struct MainHouseInfo: Codable {
            let selectedAmenities: [SelectedAmenities]
            
            struct SelectedAmenities: Codable {
                let header: String
                let content: String
            }
        }
    }
}
