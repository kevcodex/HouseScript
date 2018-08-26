//
//  DateFormatterUtil.swift
//  Source
//
//  Created by Kirby on 8/26/18.
//

import Foundation

final class DateFormatterUtil {
    static let shared = DateFormatterUtil()
    
    private var dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
    }
    
    func string(from date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
