//
//  FeaturedView.swift (Relevant Section)
//  NPSExplorer
//

import SwiftUI

struct FeaturedView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Binding var navigateToSearch: Bool
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.2, blue: 0.3), Color(red: 0.2, green: 0.3, blue: 0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if networkManager.isLoadingParks {
                MountainLoadingView(text: "Loading parks...")
            } else if let error = networkManager.parksError {
                ErrorView(error: error, retryAction: {
                    Task {
                        await networkManager.fetchParks()
                    }
                })
            } else if !networkManager.parks.isEmpty {
                // Rest of the view content...
            }
        }
        .navigationBarHidden(true)
    }
}
