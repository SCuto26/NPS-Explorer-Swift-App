//
//  ComponentViews.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI

struct LoadingView: View {
    let text: String
    
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
                .padding()
            
            Text(text)
                .foregroundColor(.white)
                .font(.headline)
        }
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 50))
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(error)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}
