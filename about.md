# NPS Explorer

NPS Explorer is an application designed to help adventurers explore the various national parks within the US. The app features only national parks from the National Park Service API (excluding monuments, memorials, etc.) and provides detailed information about each park's unique characteristics, amenities, operating hours, and current alerts. This app serves as both a planning tool for future trips and an informational resource while visiting parks.

<br>

**About the API**

NPS Explorer utilizes the National Park Service (NPS) API to retrieve comprehensive data about U.S. national parks, monuments, and memorials. This official API provides access to information about parks, their amenities, campgrounds, activities, and more, enabling the app to display the most current and accurate information available.

API Documentation Link:
https://www.nps.gov/subjects/developer/api-documentation.htm

<br>

**Key Features**

- Browse featured nearby national parks based on user location
- Search all national parks by name or park code
- Filter parks by state with an intuitive state selection interface
- View detailed park information including descriptions, amenities, and maps
- Check current park alerts, including weather warnings and road closures
- See real-time operating hours for each day of the week
- Explore park location with integrated maps

<br>

**Notable Implementations**

<br>

*Custom Loading Animation*

One feature I'd like to highlight is the custom mountain loading screen animation. While thinking of ways to fulfill the animation requirement of the project, I wanted to play with custom shapes and colors to create something both visually appealing and thematically connected to the app's purpose. The animation shows mountains rising from the ground, snow caps forming, and trees appearing, finishing off with a sun rising—all drawn using custom SwiftUI shapes and paths.
Creating this animation involved a ton of guessing and checking with the  timing, sizing, and positioning of elements. The process tested my knowledge of SwiftUI's animation system and helped me gain a deeper understanding of how to sequence complex animations. Additionally, by learning and implementing a minimum duration timer mechanism, I ensured users could appreciate the full animation sequence even when data loaded quickly.

<br>

*Location-Based Park Discovery*

Given the whole purpose of my app is to help adventurers seek out the natural beauty around them, I implemented a location-aware featured tab that determines the five closest national parks to the user's current location. This provides an intuitive starting point for planning adventures to nearby parks.
Implementing this feature required learning about Apple's location services framework and understanding the permission request flow. I had to calculate distances between the user and all national parks, then sort and present them with appropriate distance formatting (feet for very close parks, miles with decimal places for moderate distances, and rounded miles for farther parks). YouTube tutorials and Apple's documentation were great resources for implementing this functionality correctly.

<br>

**App Icon Credits**

The app icon for NPS Explorer was created by myself, featuring a black mountainous landscape image sourced from the following vector website:

https://www.freepik.com/premium-vector/majestic-mountain-silhouette_393544826.htm#fromView=keyword&page=1&position=26&uuid=379e6c9a-070f-4f4a-b1f0-854b3b002849&query=Black+Mountain

All national park photos are credited within the app and are directly sourced from the National Park Service API.
