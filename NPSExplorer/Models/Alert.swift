//
//  Alert.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import Foundation

struct Alert: Identifiable, Hashable, Codable {
    var id: String
    var title: String
    var description: String
    var parkCode: String
    var category: String
    var lastIndexedDate: String
    
    // Computed property to format the last indexed date for display
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"
        
        if let date = dateFormatter.date(from: lastIndexedDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return lastIndexedDate
    }
}
