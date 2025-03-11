//
//  Amenity.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import Foundation

struct Amenity: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var parks: [ParkWithAmenity]
    
    struct ParkWithAmenity: Identifiable, Hashable, Codable {
        var states: String
        var parkCode: String
        var fullName: String
        var url: String
        var name: String
        
        // Using parkCode as the identifier
        var id: String { parkCode }
    }
    
    // Emoji mapping for different amenity types
    static func emojiForAmenity(_ amenityName: String) -> String {
        let lowercaseName = amenityName.lowercased()
        
        // Custom emoji mappings based on your specifications
        switch lowercaseName {
        case let name where name.contains("accessible rooms"):
            return "♿"
        case let name where name.contains("benches") || name.contains("seating"):
            return "🪑"
        case let name where name.contains("fire extinguisher"):
            return "🧯"
        case let name where name.contains("firewood for sale") || name.contains("firewood available"):
            return "🪵"
        case let name where name.contains("electric car charging"):
            return "⚡"
        case let name where name.contains("fire pit"):
            return "🕳️"
        case let name where name.contains("assistive listening"):
            return "👂"
        case let name where name.contains("audio description"):
            return "👂"
        case let name where name.contains("amphitheater"):
            return "🏟️"
        case let name where name.contains("baby changing"):
            return "🚼"
        case let name where name.contains("bus") || name.contains("shuttle stop"):
            return "🚌"
        case let name where name.contains("beach") || name.contains("water access"):
            return "🏖️"
        case let name where name.contains("electrical hookup"):
            return "🔋"
        case let name where name.contains("automated entrance"):
            return "🚪"
        case let name where name.contains("entrance passes"):
            return "🎟️"
        case let name where name.contains("braille"):
            return "♿"
        case let name where name.contains("first aid") || name.contains("medical care"):
            return "⛑️"
        case let name where name.contains("aed") || name.contains("defibrillator"):
            return "❤️"
        case let name where name.contains("animal-safe") || name.contains("food storage"):
            return "🐻"
        case let name where name.contains("backcountry permits"):
            return "📜"
        case let name where name.contains("electrical outlet") || name.contains("cell phone charging"):
            return "🔋"
        case let name where name.contains("ferry") || name.contains("passenger"):
            return "⛴️"
        case let name where name.contains("fishing licenses"):
            return "🐟"
        case let name where name.contains("food") || name.contains("drink") || name.contains("cafeteria") || name.contains("coffee"):
            return "🍽️"
        case let name where name.contains("bicycle") || name.contains("bike"):
            return "🚲"
        case let name where name.contains("dock") || name.contains("pier"):
            return "🚢"
        case let name where name.contains("canoe") || name.contains("kayak") || name.contains("small boat") || name.contains("boat launch"):
            return "🚣"
        case let name where name.contains("atm") || name.contains("cash"):
            return "💰"
        case let name where name.contains("restroom") || name.contains("toilet") || name.contains("bathroom"):
            return "🚻"
        case let name where name.contains("wifi") || name.contains("cellular"):
            return "📶"
        case let name where name.contains("shower"):
            return "🚿"
        case let name where name.contains("picnic"):
            return "🧺"
        case let name where name.contains("parking"):
            return "🅿️"
        case let name where name.contains("information") || name.contains("visitor center"):
            return "ℹ️"
        case let name where name.contains("wheelchair") || name.contains("accessible"):
            return "♿"
        case let name where name.contains("trash") || name.contains("garbage"):
            return "🗑️"
        case let name where name.contains("lodge") || name.contains("hotel") || name.contains("cabin"):
            return "🏨"
        case let name where name.contains("trail") || name.contains("hike"):
            return "🥾"
        case let name where name.contains("elevator"):
            return "🛗"
        default:
            return "🏕️" // Default park emoji
        }
    }
}
