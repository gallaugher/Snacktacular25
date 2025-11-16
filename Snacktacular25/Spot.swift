//  Spot.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import Foundation
import FirebaseFirestore

struct Spot: Identifiable, Codable {
    @DocumentID var id: String?
    var name = ""
    var address = ""
}

extension Spot {
    static var preview: Spot {
        let newSpot = Spot(id: "1", name: "Boston Public Market", address: "Boston, MA")

        return newSpot
    }
}
