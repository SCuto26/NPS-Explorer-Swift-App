//
//  Park.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct Park: Identifiable, Hashable, Codable {
    var id: String
    var fullName: String
    var parkCode: String
    var description: String
    var latitude: String
    var longitude: String
    var states: String
    var name: String
    var designation: String
    var images: [ParkImage]
    var activities: [Activity]
    var operatingHours: [OperatingHours]
    var addresses: [ParkAddress]
    
    // Computed property for location coordinates
    var locationCoordinate: CLLocationCoordinate2D? {
        if let lat = Double(latitude), let long = Double(longitude) {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        return nil
    }
    
    // Nested structures to match API response format
    struct Activity: Identifiable, Hashable, Codable {
        var id: String
        var name: String
    }
    
    struct ParkImage: Identifiable, Hashable, Codable {
        var id: UUID? = UUID()
        var credit: String
        var title: String
        var altText: String
        var caption: String
        var url: String
    }
    
    struct OperatingHours: Identifiable, Hashable, Codable {
        var id: UUID? = UUID()
        var description: String
        var standardHours: StandardHours
        var name: String
    }
    
    struct StandardHours: Hashable, Codable {
        var monday: String
        var tuesday: String
        var wednesday: String
        var thursday: String
        var friday: String
        var saturday: String
        var sunday: String
    }
    
    struct ParkAddress: Identifiable, Hashable, Codable {
        var id: UUID? = UUID()
        var postalCode: String
        var city: String
        var stateCode: String
        var line1: String
        var type: String
    }
}
