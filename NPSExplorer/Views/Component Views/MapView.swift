//
//  MapView.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI
import MapKit

struct ParkMapView: View {
    var coordinate: CLLocationCoordinate2D
    var name: String
    
    var body: some View {
        Map {
            Marker(name, coordinate: coordinate)
                .tint(.blue)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

struct ParkMapView_Previews: PreviewProvider {
    static var previews: some View {
        ParkMapView(
            coordinate: CLLocationCoordinate2D(latitude: 37.5858662, longitude: -85.67330523),
            name: "Abraham Lincoln Birthplace"
        )
        .previewLayout(.fixed(width: 400, height: 300))
    }
}
