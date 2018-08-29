//
//  AboveTheFold.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation

struct AboveTheFold: Codable {
    let selectedAmenities: [SelectedAmenities]?
    
    private enum RootKeys: String, CodingKey {
        case payload
        case mainHouseInfo
    }
    
    private enum PayloadKeys: String, CodingKey {
        case mainHouseInfo
    }
    
    private enum MainHouseInfoKeys: String, CodingKey {
        case selectedAmenities
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        let payloadContainer = try container.nestedContainer(keyedBy: PayloadKeys.self,
                                                             forKey: .payload)
        
        let mainHouseInfoContainer = try payloadContainer.nestedContainer(keyedBy: MainHouseInfoKeys.self,
                                                                          forKey: .mainHouseInfo)
        
        selectedAmenities = try mainHouseInfoContainer.decode([SelectedAmenities].self, forKey: .selectedAmenities)
    }
    
    struct SelectedAmenities: Codable {
        let header: String
        let content: String
    }
}
