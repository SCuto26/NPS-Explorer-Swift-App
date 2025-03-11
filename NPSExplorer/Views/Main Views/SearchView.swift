//
//  SearchView.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var searchText = ""
    @State private var showingStateFilter = false
    @State private var selectedStates: Set<String> = []
    
    // Loading state management
    @State private var isLoading = false
    @State private var loadingStartTime: Date?
    
    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    MountainLoadingView(text: "")
                        .padding()
                    
                    Text("Finding nearby parks...")
                        .foregroundColor(.black)
                        .padding(.top, 30)
                }
            } else if let error = networkManager.parksError {
                ErrorView(error: error, retryAction: {
                    startLoadingWithTask {
                        await networkManager.fetchParks()
                    }
                })
            } else {
                // State filter chip display
                if !selectedStates.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(selectedStates).sorted(), id: \.self) { state in
                                HStack {
                                    Text(state)
                                    
                                    Button(action: {
                                        selectedStates.remove(state)
                                        startLoadingWithTask {
                                            await networkManager.fetchParks(stateFilter: Array(selectedStates))
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                            
                            Button(action: {
                                selectedStates.removeAll()
                                startLoadingWithTask {
                                    await networkManager.fetchParks()
                                }
                            }) {
                                Text("Clear All")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
                
                // Park list - only showing national parks
                List {
                    ForEach(networkManager.filteredParks) { park in
                        NavigationLink(destination: ParkDetailView(park: park).environmentObject(networkManager)) {
                            ParkRow(park: park)
                        }
                    }
                }
                .listStyle(.plain)
                .animation(.default, value: networkManager.filteredParks)
            }
        }
        .navigationTitle("National Parks")
        .searchable(text: $searchText, prompt: "Search by name or park code")
        .onChange(of: searchText) {
            networkManager.filterParks(by: searchText)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingStateFilter = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingStateFilter) {
            StateFilterView(selectedStates: $selectedStates, allParks: networkManager.nationalParks) {
                showingStateFilter = false
                startLoadingWithTask {
                    await networkManager.fetchParks(stateFilter: Array(selectedStates))
                }
            }
        }
        .onAppear {
            // Check if we need to load parks
            if networkManager.parks.isEmpty && !networkManager.isLoadingParks && !isLoading {
                startLoadingWithTask {
                    await networkManager.fetchParks()
                }
            }
        }
        .onChange(of: networkManager.isLoadingParks) { _, newValue in
            if !newValue && loadingStartTime != nil {
                // API request finished - check if we need to keep showing the loading screen
                let elapsedTime = Date().timeIntervalSince(loadingStartTime!)
                let minimumDuration: TimeInterval = 6.0
                
                if elapsedTime < minimumDuration {
                    // Still need to show the loading screen for a bit longer
                    let remainingTime = minimumDuration - elapsedTime
                    DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
                        isLoading = false
                        loadingStartTime = nil
                    }
                } else {
                    // Minimum duration already elapsed, can hide loading screen
                    isLoading = false
                    loadingStartTime = nil
                }
            }
        }
    }
    
    // Helper function to start loading with timing
    private func startLoadingWithTask(_ task: @escaping () async -> Void) {
        // Start loading timer
        isLoading = true
        loadingStartTime = Date()
        
        // Run the async task
        Task {
            await task()
        }
    }
}
