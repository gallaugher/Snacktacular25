//  PlaceLookupViewMode.swift
//  LocationAndPlaceLookup
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import Foundation
import MapKit

@MainActor
@Observable
class PlaceLookupViewModel {
    var places: [Place] = []
    
    func Search(text: String, region: MKCoordinateRegion) async throws {
        // Create a search reqeust
        let searchRequest = MKLocalSearch.Request()
        // pass in search text to the request
        searchRequest.naturalLanguageQuery = text
        // Establish a search region
        searchRequest.region = region
        // Now create the search object that performs the search
        let search = MKLocalSearch(request: searchRequest)
        // Run the search
        let response = try await search.start()
        if response.mapItems.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "⁉️ No location found"])
        }
        self.places = response.mapItems.map(Place.init)
    }
}
