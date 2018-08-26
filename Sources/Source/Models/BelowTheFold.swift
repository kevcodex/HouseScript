//
//  BelowTheFold.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation

// TODO: Clean
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
                let baths: Double
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
                let eventType: EventType?
                let eventTimeInterval: TimeInterval?
                
                let eventDate: Date?
                
                var eventDateString: String? {
                    guard let eventDate = eventDate else {
                        return nil
                    }
                    
                    return DateFormatterUtil.shared.string(from: eventDate, format: "MM/dd/yy")
                }
                
                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: Keys.self)
                    
                    price = try values.decodeIfPresent(Int.self, forKey: Keys.price)
                    url = try values.decodeIfPresent(String.self, forKey: Keys.url)
                    
                    let eventString = try values.decodeIfPresent(String.self, forKey: .eventDescription)
                    eventType = EventType(string: eventString)
                    
                    eventTimeInterval = try values.decodeIfPresent(TimeInterval.self, forKey: Keys.eventDate)
                    
                    let eventDateSeconds = TimeInterval(eventTimeInterval ?? 0) / 1000
                    eventDate = Date(timeIntervalSince1970: eventDateSeconds)
                }
                
                enum Keys: String, CodingKey {
                    case price
                    case url
                    case eventDescription = "eventDescription"
                    case eventDate = "eventDate"
                }
                
                enum EventType: String, CustomStringConvertible, Codable {
                    case active
                    case pending
                    case sold
                    case unknown
                    
                    init?(string: String?) {
                        
                        guard let string = string else {
                            return nil
                        }
                        
                        let lowercased = string.lowercased()
                        
                        // Different strings of potential active types
                        let activeArrayStrings = ["active", "listed", "changed"]
                        
                        for string in activeArrayStrings {
                            if lowercased.contains(string) {
                                self = .active
                                return
                            }
                        }
                        
                        if lowercased.contains("pending") {
                            self = .pending
                        } else if lowercased.contains("sold") {
                            self = .sold
                        } else {
                            self = .unknown
                        }
                    }
                    
                    var description: String {
                        switch self {
                            
                        case .active:
                            return "Active"
                        case .pending:
                            return "Pending"
                        case .sold:
                            return "Sold"
                        case .unknown:
                            return "Unknown"
                        }
                    }
                }
            }
        }
    }
}
