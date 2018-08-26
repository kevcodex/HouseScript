//
//  CSVWriter.swift
//  Source
//
//  Created by Kirby on 8/25/18.
//

import Foundation

struct CSVWriter {
    
    /// Append new columns by breaking out each row and then add each column in columns to the end of each row. Then rewrite the CSV with the new modified rows.
    /// - parameter columns: The new columns to be added.
    /// - complexity: O(3n^2)? where n is the number of rows in CSV.
    static func addNewColumns(_ columns: [String], to url: URL) throws {
        let csvString = try String(contentsOf: url, encoding: .utf8)
        
        let csvRows = csvString.split(separator: "\n").map { String($0) }
        
        var newCSVRows: [String] = []
        
        if csvRows.isEmpty {
            newCSVRows.append(contentsOf: columns)
        } else {
            csvRows.enumerated().forEach { (index, rowString) in
                var newRowString = rowString
                let newColumn = columns[index]
                newRowString.append(",\(newColumn)")
                newCSVRows.append(newRowString)
            }
        }
        
        let newCSVString = newCSVRows.joined(separator: "\n")
        
        guard let data = newCSVString.data(using: .utf8) else {
            return
        }
        
        try data.write(to: url, options: .atomic)
    }
    
    /// Add new rows at the end of the file.
    /// - complexity: O(n) where n is the number of rows to add
    static func addNewRows(_ rows: [String], to url: URL) throws {
        for row in rows {
            guard let data = row.data(using: .utf8) else {
                continue
            }
            
            if let fileHandle = FileHandle(forWritingAtPath: url.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try data.write(to: url, options: .atomic)
            }
        }
    }
}
