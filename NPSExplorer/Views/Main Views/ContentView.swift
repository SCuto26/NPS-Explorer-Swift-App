//
//  ContentView.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var locationManager = LocationManager()
    @State private var selection: Tab = .featured
    
    enum Tab {
        case featured
        case search
    }
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                FeaturedParks()
            }
            .tabItem {
                Label("Featured", systemImage: "star.fill")
            }
            .tag(Tab.featured)
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Explore", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)
        }
        .environmentObject(networkManager)
        .task {
            // Load all data when the app starts
            await networkManager.fetchParks()
            await networkManager.fetchAmenities()
            await networkManager.fetchAlerts()
            
            // Update user location if available
            if let location = locationManager.location {
                networkManager.userLocation = location
                networkManager.updateNearbyParks(from: location)
            }
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                networkManager.userLocation = location
                networkManager.updateNearbyParks(from: location)
            }
        }
    }
}

#Preview {
    ContentView()
}
