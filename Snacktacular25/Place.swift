//  Place.swift
//  LocationAndPlaceLookup
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import Foundation
import MapKit

struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    init(location: CLLocation) async {
        // Use the new MKReverseGeocodingRequest
        do {
            let request = MKReverseGeocodingRequest(location: location)
            guard let mapItem = try await request?.mapItems.first else {
                self.init(mapItem: MKMapItem())
                return
            }
            self.init(mapItem: mapItem)
        } catch {
            print("😡🌎 GEOCODING ERROR: \(error.localizedDescription)")
            self.init(mapItem: MKMapItem())
        }
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.location.coordinate.latitude
    }
    
    var longitude: Double {
        self.mapItem.location.coordinate.longitude
    }
    
    var address: String {
        print("mapItem.address?.shortAddress: \(mapItem.address?.shortAddress ?? "")")
        return mapItem.address?.shortAddress ?? ""
    }
}
