//
//  ParkRow.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/1/25.
//

import SwiftUI

struct ParkRow: View {
    let park: Park
    
    var body: some View {
        HStack(spacing: 12) {
            // Park thumbnail
            if !park.images.isEmpty {
                AsyncImage(url: URL(string: park.images[0].url)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 60)
                            .foregroundColor(.gray)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 60)
                            .overlay(ProgressView())
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 60)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(park.fullName)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text(park.states)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(park.parkCode.uppercased())
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ParkRow_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = """
        {
            "id": "77E0D7F0-1942-494A-ACE2-9004D2BDC59E",
            "parkCode": "abli",
            "fullName": "Abraham Lincoln Birthplace National Historical Park",
            "name": "Abraham Lincoln Birthplace",
            "designation": "National Historical Park",
            "description": "For over a century people from around the world have come to rural Central Kentucky to honor the humble beginnings of our 16th president, Abraham Lincoln.",
            "latitude": "37.5858662",
            "longitude": "-85.67330523",
            "states": "KY",
            "images": [
                {
                    "credit": "NPS Photo",
                    "title": "The Memorial Building with fall colors",
                    "altText": "The Memorial Building surrounded by fall colors",
                    "caption": "Over 200,000 people a year come to walk up the steps of the Memorial Building to visit the site where Abraham Lincoln was born",
                    "url": "https://www.nps.gov/common/uploads/structured_data/3C861078-1DD8-B71B-0B774A242EF6A706.jpg"
                }
            ]
        }
        """
        
        if let samplePark = try? JSONDecoder().decode(Park.self, from: Data(sampleData.utf8)) {
            List {
                ParkRow(park: samplePark)
            }
            .listStyle(.plain)
            .previewLayout(.sizeThatFits)
        } else {
            Text("Failed to create preview")
        }
    }
}
