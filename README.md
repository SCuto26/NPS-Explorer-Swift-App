# NPS Explorer

NPS Explorer is an iOS application designed to help adventurers explore the various national parks within the United States. The app leverages the National Park Service API to provide detailed information about each park's unique characteristics, amenities, operating hours, and current alerts. This app serves as both a planning tool for future trips and an informational resource while visiting parks.

## Features

- **Location-Based Discovery**: Browse featured nearby national parks based on your current location
- **Comprehensive Search**: Search all national parks by name or park code
- **State Filtering**: Filter parks by state with an intuitive state selection interface
- **Detailed Information**: View park descriptions, amenities, and interactive maps
- **Real-Time Alerts**: Check current park alerts, including weather warnings and road closures
- **Operating Hours**: See real-time operating hours for each day of the week
- **Interactive Maps**: Explore park locations with integrated maps

## Technical Highlights

### Custom Loading Animation
The app features a custom mountain loading screen animation showing mountains rising from the ground, snow caps forming, trees appearing, and a sun rising—all drawn using custom SwiftUI shapes and paths. This animation involves sequenced timing and positioning of elements, demonstrating advanced SwiftUI animation capabilities.

### Location-Based Park Discovery
The app implements location-aware functionality that determines the five closest national parks to the user's current location, providing an intuitive starting point for planning adventures to nearby parks. This involved Apple's location services framework, calculating distances between the user and all national parks, and presenting them with appropriate distance formatting.

## Technology Stack

- Swift & SwiftUI
- Core Location for location services
- MapKit for interactive maps
- Asynchronous API calls
- Custom animations and graphics

## App Icon Credits

The app icon was created by the developer, featuring a black mountainous landscape image sourced from [this vector website](https://www.freepik.com/premium-vector/majestic-mountain-silhouette_393544826.htm#fromView=keyword&page=1&position=26&uuid=379e6c9a-070f-4f4a-b1f0-854b3b002849&query=Black+Mountain).

All national park photos are credited within the app and are directly sourced from the National Park Service API.
