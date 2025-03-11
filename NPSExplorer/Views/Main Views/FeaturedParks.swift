//
//  FeaturedParks.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI
import CoreLocation

struct FeaturedParks: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @State private var isLoading = false
    @State private var loadingStartTime: Date?
    @State private var loadedParks = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Header with Animation
                PageHeader()
                    .padding(.top, 20)
                
                if networkManager.nearbyParks.isEmpty || isLoading {
                    VStack(spacing: 16) {
                        if networkManager.userLocation == nil {
                            Text("Location services are disabled")
                                .font(.headline)
                            
                            Text("Enable location services to see nearby parks")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Enable Location") {
                                // This will prompt the user to enable location services
                                let manager = CLLocationManager()
                                manager.requestWhenInUseAuthorization()
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            .padding()
                        } else if isLoading {
                            // Loading animation
                            VStack {
                                MountainLoadingView(text: "")
                                    .padding()
                                
                                Text("Finding nearby parks...")
                                    .foregroundColor(.black)
                                    .padding(.top, 30)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Featured Parks List
                    VStack(spacing: 24) {
                        ForEach(networkManager.nearbyParks) { park in
                            NavigationLink {
                                ParkDetailView(park: park).environmentObject(networkManager)
                            } label: {
                                FeaturedParkCard(park: park)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Featured")
        .onChange(of: networkManager.isLoadingParks) { _, newIsLoading in
            handleLoadingChange(isLoading: newIsLoading)
        }
        .onAppear {
            // If we need to load parks and aren't already loading
            if networkManager.nearbyParks.isEmpty && networkManager.userLocation != nil && !networkManager.isLoadingParks && !isLoading {
                startLoading()
                
                Task {
                    await networkManager.fetchParks()
                }
            }
        }
    }
    
    private func startLoading() {
        loadingStartTime = Date()
        isLoading = true
        loadedParks = false
    }
    
    // Followed the following YouTube tutorial to figure out how to
    // incorporate DispatchQueue with a loading screen animation that
    // needs to run before information populates the screen:
    // https://youtu.be/1RD8-5_Zsws?si=yR8Rfot8spKFsuZA
    private func handleLoadingChange(isLoading: Bool) {
        if !isLoading && networkManager.nearbyParks.isEmpty == false {
            // Parks loaded
            loadedParks = true
            
            // Check if minimum display time has passed
            if let startTime = loadingStartTime {
                let elapsedTime = Date().timeIntervalSince(startTime)
                let minimumDuration: TimeInterval = 6.0
                
                if elapsedTime < minimumDuration {
                    // Wait until minimum time has passed
                    let remainingTime = minimumDuration - elapsedTime
                    DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
                        self.isLoading = false
                    }
                } else {
                    // Minimum time already passed, stop loading immediately
                    self.isLoading = false
                }
            } else {
                // No start time recorded (shouldn't happen), stop loading
                self.isLoading = false
            }
        } else if isLoading && !self.isLoading {
            // Network manager started loading
            startLoading()
        }
    }
}

struct FeaturedParkCard: View {
    let park: Park
    @EnvironmentObject private var networkManager: NetworkManager
    
    // Convert state abbreviations to full names
    var stateNames: String {
        let stateAbbreviations = park.states.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        let stateNameMap: [String: String] = [
            "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas", "CA": "California",
            "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware", "FL": "Florida", "GA": "Georgia",
            "HI": "Hawaii", "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa",
            "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
            "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi", "MO": "Missouri",
            "MT": "Montana", "NE": "Nebraska", "NV": "Nevada", "NH": "New Hampshire", "NJ": "New Jersey",
            "NM": "New Mexico", "NY": "New York", "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio",
            "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina",
            "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah", "VT": "Vermont",
            "VA": "Virginia", "WA": "Washington", "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming",
            "DC": "District of Columbia", "AS": "American Samoa", "GU": "Guam", "MP": "Northern Mariana Islands",
            "PR": "Puerto Rico", "VI": "U.S. Virgin Islands"
        ]
        
        let fullNames = stateAbbreviations.map { stateAbbr in
            stateNameMap[stateAbbr] ?? stateAbbr
        }
        
        return fullNames.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !park.images.isEmpty {
                AsyncImage(url: URL(string: park.images[0].url)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    } else if phase.error != nil {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.gray)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                            )
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    )
            }
            
            HStack {
                // Park icon and info
                HStack(spacing: 12) {
                    // Park Icon
                    Image(systemName: "mountain.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(park.fullName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        // Full state names instead of abbreviations
                        Text(stateNames)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Distance indicator
                Text(networkManager.formattedDistance(for: park.id))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 8)
    }
}

struct PageHeader: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Discover")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Nearby National Parks")
                .font(.title)
                .fontWeight(.bold)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct FeaturedParks_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeaturedParks()
                .environmentObject(NetworkManager())
        }
    }
}
