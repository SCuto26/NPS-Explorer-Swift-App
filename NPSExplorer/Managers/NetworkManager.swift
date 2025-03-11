//
//  NetworkManager.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import Foundation
import SwiftUI
import CoreLocation

@MainActor
class NetworkManager: ObservableObject {
    // API Key for National Park Service API
    private let apiKey = "zuBAeWhEXo54aKYpe8DdkrRLxmdSkOoR3W1g5I3t"
    private let baseURL = "https://developer.nps.gov/api/v1"
    
    // Published properties for data
    @Published var parks: [Park] = []
    @Published var nationalParks: [Park] = [] // Only actual national parks
    @Published var amenities: [Amenity] = []
    @Published var alerts: [Alert] = []
    @Published var filteredParks: [Park] = []
    
    // User location
    @Published var userLocation: CLLocation?
    @Published var nearbyParks: [Park] = []
    @Published var parkDistances: [String: Double] = [:]
    
    // Loading states
    @Published var isLoadingParks = false
    @Published var isLoadingAmenities = false
    @Published var isLoadingAlerts = false
    @Published var isLoadingLocation = false
    
    // Error states
    @Published var parksError: String? = nil
    @Published var amenitiesError: String? = nil
    @Published var alertsError: String? = nil
    @Published var locationError: String? = nil
    
    // Initialize and fetch all required data
    init() {}
    
    // MARK: - API Calls
    
    // Fetch parks data
    func fetchParks(stateFilter: [String]? = nil) async {
        isLoadingParks = true
        parksError = nil
        
        var urlComponents = URLComponents(string: "\(baseURL)/parks")
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "limit", value: "500") // Increase limit to get all parks
        ]
        
        // Add state filter if provided
        if let stateFilter = stateFilter, !stateFilter.isEmpty {
            let stateString = stateFilter.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "stateCode", value: stateString))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            parksError = "Invalid URL"
            isLoadingParks = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                parksError = "Server error"
                isLoadingParks = false
                return
            }
            
            let parksResponse = try JSONDecoder().decode(ParksResponse.self, from: data)
            
            // Filter for only National Parks (designation contains "National Park")
            parks = parksResponse.data
            nationalParks = parksResponse.data.filter { park in
                park.designation.contains("National Park") &&
                !park.designation.contains("National Historical Park") &&
                !park.designation.contains("National Memorial")
            }
            
            // Use national parks as the default filtered parks
            filteredParks = nationalParks
            
            // Update nearby parks if user location is available
            if let location = userLocation {
                updateNearbyParks(from: location)
            }
            
            isLoadingParks = false
        } catch {
            parksError = "Failed to load parks: \(error.localizedDescription)"
            isLoadingParks = false
        }
    }
    
    // Update nearby parks based on user location
    func updateNearbyParks(from location: CLLocation) {
        // Calculate distances to all national parks
        let parksWithDistances = nationalParks.compactMap { park -> (Park, CLLocationDistance)? in
            guard let coordinate = park.locationCoordinate else { return nil }
            let parkLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = location.distance(from: parkLocation)
            return (park, distance)
        }
        
        // Sort by distance and take top 5
        let sortedParks = parksWithDistances.sorted { $0.1 < $1.1 }
        
        // Create a dictionary of distances for easy lookup
        var distanceDict: [String: Double] = [:]
        for (park, distance) in parksWithDistances {
            distanceDict[park.id] = distance
        }
        self.parkDistances = distanceDict
        
        nearbyParks = sortedParks.prefix(5).map { $0.0 }
    }
    
    // Format distance for display
    func formattedDistance(for parkId: String) -> String {
        guard let distanceInMeters = parkDistances[parkId] else {
            return "Distance unknown"
        }
        
        // Convert to miles (1 meter = 0.000621371 miles)
        let distanceInMiles = distanceInMeters * 0.000621371
        
        if distanceInMiles < 1 {
            // Less than 1 mile, show in feet
            let feet = Int(distanceInMiles * 5280)
            return "\(feet) ft"
        } else if distanceInMiles < 10 {
            // Less than 10 miles, show with 1 decimal place
            return String(format: "%.1f mi", distanceInMiles)
        } else {
            // More than 10 miles, show as whole number
            return "\(Int(distanceInMiles)) mi"
        }
    }
    
    // Fetch amenities data
    func fetchAmenities() async {
        isLoadingAmenities = true
        amenitiesError = nil
        
        guard let url = URL(string: "\(baseURL)/amenities/parksplaces?api_key=\(apiKey)") else {
            amenitiesError = "Invalid URL"
            isLoadingAmenities = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                amenitiesError = "Server error"
                isLoadingAmenities = false
                return
            }
            
            let amenitiesResponse = try JSONDecoder().decode(AmenitiesResponse.self, from: data)
            
            amenities = amenitiesResponse.data.flatMap { $0 }
            isLoadingAmenities = false
        } catch {
            amenitiesError = "Failed to load amenities: \(error.localizedDescription)"
            isLoadingAmenities = false
        }
    }
    
    // Fetch alerts data
    func fetchAlerts() async {
        isLoadingAlerts = true
        alertsError = nil
        
        guard let url = URL(string: "\(baseURL)/alerts?api_key=\(apiKey)") else {
            alertsError = "Invalid URL"
            isLoadingAlerts = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                alertsError = "Server error"
                isLoadingAlerts = false
                return
            }
            
            let alertsResponse = try JSONDecoder().decode(AlertsResponse.self, from: data)
            
            alerts = alertsResponse.data
            isLoadingAlerts = false
        } catch {
            alertsError = "Failed to load alerts: \(error.localizedDescription)"
            isLoadingAlerts = false
        }
    }
    
    // Filter parks by search text
    func filterParks(by searchText: String) {
        if searchText.isEmpty {
            filteredParks = nationalParks
        } else {
            filteredParks = nationalParks.filter { park in
                park.fullName.localizedCaseInsensitiveContains(searchText) ||
                park.parkCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Get amenities for a specific park
    func getAmenities(for parkCode: String) -> [Amenity] {
        return amenities.filter { amenity in
            amenity.parks.contains { $0.parkCode == parkCode }
        }
    }
    
    // Get alerts for a specific park
    func getAlerts(for parkCode: String) -> [Alert] {
        return alerts.filter { $0.parkCode == parkCode }
            .sorted { $0.lastIndexedDate > $1.lastIndexedDate }
    }
}

// MARK: - Response Structures

// Response container for Parks API
struct ParksResponse: Codable {
    var total: String
    var limit: String
    var start: String
    var data: [Park]
}

// Response container for Amenities API
struct AmenitiesResponse: Codable {
    var total: String
    var limit: String
    var start: String
    var data: [[Amenity]]
}

// Response container for Alerts API
struct AlertsResponse: Codable {
    var total: String
    var limit: String
    var start: String
    var data: [Alert]
}
