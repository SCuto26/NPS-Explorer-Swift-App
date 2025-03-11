//
//  ParkDetailView.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI
import MapKit

struct ParkDetailView: View {
    let park: Park
    @EnvironmentObject var networkManager: NetworkManager
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    
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
        ScrollViewReader { scrollProxy in
            ScrollView {
                // Track scroll position
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Park Image Header
                    if !park.images.isEmpty {
                        ParkImageHeader(park: park)
                    }
                    
                    // Content Sections
                    VStack(alignment: .leading, spacing: 20) {
                        // Park Name and Code Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(park.fullName)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .id("parkTitle")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                // State name first, then park code
                                Text(stateNames)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text("•")
                                    .foregroundStyle(.secondary)
                                
                                Text("Park Code: \(park.parkCode.uppercased())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Description Section
                        SectionContainer(title: "Description") {
                            Text(park.description)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Map Section
                        if let coordinate = park.locationCoordinate {
                            SectionContainer(title: "Location") {
                                Map(initialPosition: .region(MKCoordinateRegion(
                                    center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                ))) {
                                    Marker(park.name, coordinate: coordinate)
                                        .tint(.blue)
                                }
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        // Amenities Section
                        if !networkManager.isLoadingAmenities && networkManager.amenitiesError == nil {
                            let parkAmenities = processAmenities(networkManager.getAmenities(for: park.parkCode))
                            if !parkAmenities.isEmpty {
                                SectionContainer(title: "Amenities") {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                                        ForEach(parkAmenities, id: \.name) { amenity in
                                            AmenityItem(name: amenity.name, emoji: amenity.emoji)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Operating Hours Section
                        if !park.operatingHours.isEmpty {
                            SectionContainer(title: "Operating Hours") {
                                OperatingHoursView(operatingHours: park.operatingHours[0])
                            }
                        }
                        
                        // Alerts Section
                        if !networkManager.isLoadingAlerts && networkManager.alertsError == nil {
                            let parkAlerts = networkManager.getAlerts(for: park.parkCode)
                            if !parkAlerts.isEmpty {
                                SectionContainer(title: "Recent Alerts", spacing: 10) {
                                    VStack(spacing: 10) {
                                        ForEach(parkAlerts.prefix(3), id: \.id) { alert in
                                            AlertItem(alert: alert)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if scrollOffset < -150 {
                    Text(park.name)
                        .font(.headline)
                        .lineLimit(1)
                        .transition(.opacity)
                }
            }
            
            // Photo credit in the navigation bar area
            ToolbarItem(placement: .navigationBarTrailing) {
                if !park.images.isEmpty {
                    Text("Photo Credit: \(park.images[0].credit)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // Process amenities to group related items and apply custom emojis
    func processAmenities(_ amenities: [Amenity]) -> [(name: String, emoji: String)] {
        var groupedAmenities: [String: String] = [:]
        var processedAmenities: [(name: String, emoji: String)] = []
        
        // Group prefixes
        let groupPrefixes = [
            "Food/Drink",
            "Assistive Listening Systems",
            "Audio Description",
            "Bicycle",
            "First Aid"
        ]
        
        // Process amenities
        for amenity in amenities {
            // Check if this amenity should be grouped
            var shouldGroup = false
            var groupKey = ""
            
            for prefix in groupPrefixes {
                if amenity.name.starts(with: prefix) {
                    shouldGroup = true
                    groupKey = prefix
                    break
                }
            }
            
            if shouldGroup {
                // Just add the group key once
                if groupedAmenities[groupKey] == nil {
                    // Get appropriate emoji for the group using the enhanced emojiForAmenity
                    let emoji = Amenity.emojiForAmenity(groupKey)
                    groupedAmenities[groupKey] = emoji
                }
            } else {
                // Use the enhanced emojiForAmenity function
                let emoji = Amenity.emojiForAmenity(amenity.name)
                processedAmenities.append((name: amenity.name, emoji: emoji))
            }
        }
        
        // Add the grouped amenities
        for (name, emoji) in groupedAmenities {
            processedAmenities.append((name: name, emoji: emoji))
        }
        
        return processedAmenities.sorted { $0.name < $1.name }
    }
}

// ScrollOffset preference key to track scrolling
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Supporting Views

struct ParkImageHeader: View {
    let park: Park
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: park.images[0].url)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 250)
                        .clipped()
                } else if phase.error != nil {
                    Color.gray
                        .frame(width: geometry.size.width, height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: geometry.size.width, height: 250)
                        .overlay(ProgressView())
                }
            }
        }
        .frame(height: 250)
    }
}

struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    var spacing: CGFloat = 12 // Default spacing
    
    init(title: String, spacing: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.title = title
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) { // Use the spacing parameter
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 0)
            
            content
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AmenityItem: View {
    let name: String
    let emoji: String
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
            
            Text(name)
                .font(.subheadline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct OperatingHoursView: View {
    let operatingHours: Park.OperatingHours
    
    // Helper to format and colorize operating hours
    func formattedHours(_ hours: String) -> (text: String, color: Color) {
        let lowercaseHours = hours.lowercased()
        
        if lowercaseHours.contains("open 24 hours") || lowercaseHours.contains("all day") {
            return ("Open All Day", .green)
        } else if lowercaseHours.contains("closed") {
            return ("Closed", .red)
        } else {
            return (hours, .blue)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(operatingHours.description)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 8)
            
            // Days of the week with centralized, colored times
            VStack(spacing: 8) {
                DayRow(day: "Monday", hours: operatingHours.standardHours.monday)
                DayRow(day: "Tuesday", hours: operatingHours.standardHours.tuesday)
                DayRow(day: "Wednesday", hours: operatingHours.standardHours.wednesday)
                DayRow(day: "Thursday", hours: operatingHours.standardHours.thursday)
                DayRow(day: "Friday", hours: operatingHours.standardHours.friday)
                DayRow(day: "Saturday", hours: operatingHours.standardHours.saturday)
                DayRow(day: "Sunday", hours: operatingHours.standardHours.sunday)
            }
        }
    }
    
    struct DayRow: View {
        let day: String
        let hours: String
        
        // Process the hours text and color based on content
        var formattedHours: (text: String, color: Color) {
            let lowercaseHours = hours.lowercased()
            
            if lowercaseHours.contains("open 24 hours") || lowercaseHours.contains("all day") ||
               lowercaseHours.contains("sunrise to sunset") {
                return ("Open All Day", .green)
            } else if lowercaseHours.contains("closed") {
                return ("Closed", .red)
            } else {
                return (hours, .blue)
            }
        }
        
        var body: some View {
            HStack {
                Text(day)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 90, alignment: .leading)
                
                Spacer()
                
                Text(formattedHours.text)
                    .font(.subheadline.bold())
                    .foregroundColor(formattedHours.color)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

struct AlertItem: View {
    let alert: Alert
    
    // Function to remove date prefix from description
    private func cleanDescription(_ description: String) -> String {
        // Check if the string starts with a date-like pattern (MM/DD/YYYY)
        if description.count >= 10 {
            let potentialDatePrefix = description.prefix(10)
            
            // Check if it matches the MM/DD/YYYY format with slashes
            if potentialDatePrefix.count == 10 &&
               potentialDatePrefix[potentialDatePrefix.index(potentialDatePrefix.startIndex, offsetBy: 2)] == "/" &&
               potentialDatePrefix[potentialDatePrefix.index(potentialDatePrefix.startIndex, offsetBy: 5)] == "/" {
                
                // Skip the date and any whitespace that follows
                let startIndex = description.index(description.startIndex, offsetBy: 10)
                var cleanedIndex = startIndex
                
                // Skip any whitespace that follows the date
                while cleanedIndex < description.endIndex && description[cleanedIndex].isWhitespace {
                    cleanedIndex = description.index(after: cleanedIndex)
                }
                
                return String(description[cleanedIndex...])
            }
        }
        
        return description
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // Date now appears above the description and is bold
            Text(alert.formattedDate)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.top, 2)
            
            // Use cleaned description that removes date prefix
            Text(cleanDescription(alert.description))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 1)
        }
        .padding(12)
        .cornerRadius(12)
    }
}
