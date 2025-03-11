//
//  StateFilterView.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI

struct StateFilterView: View {
    @Binding var selectedStates: Set<String>
    let allParks: [Park]
    let onDismiss: () -> Void
    @State private var searchText = ""
    
    // State abbreviation to full name mapping
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
    
    // Get unique states from all parks
    var allStateAbbreviations: [String] {
        let statesSet = allParks.flatMap { park in
            park.states.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        }
        return Array(Set(statesSet)).sorted()
    }
    
    // Convert abbreviations to full names for display
    var allStateNames: [(abbreviation: String, fullName: String)] {
        allStateAbbreviations.map { abbreviation in
            (abbreviation, stateNameMap[abbreviation] ?? abbreviation)
        }.sorted { $0.fullName < $1.fullName }
    }
    
    // Filter states based on search
    var filteredStates: [(abbreviation: String, fullName: String)] {
        if searchText.isEmpty {
            return allStateNames
        } else {
            return allStateNames.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.abbreviation.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredStates, id: \.abbreviation) { state in
                        Button(action: {
                            if selectedStates.contains(state.abbreviation) {
                                selectedStates.remove(state.abbreviation)
                            } else {
                                selectedStates.insert(state.abbreviation)
                            }
                        }) {
                            HStack {
                                Text(state.fullName)
                                Spacer()
                                if selectedStates.contains(state.abbreviation) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // Show selected count at the bottom
                if !selectedStates.isEmpty {
                    HStack {
                        Text("\(selectedStates.count) states selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Clear All") {
                            selectedStates.removeAll()
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Filter by State")
            .searchable(text: $searchText, prompt: "Search states")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onDismiss()
                    }
                    .bold()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
