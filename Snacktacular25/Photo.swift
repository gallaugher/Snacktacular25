//  Photo.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import Foundation
import FirebaseFirestore
import FirebaseAuth

class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" // This will hold the URL for loading the image
    var description = ""
    var reviewer: String = Auth.auth().currentUser?.email ?? ""
    var postedOn = Date() // current date/time
    
    init(id: String? = nil, imageURLString: String = "", description: String = "", reviewer: String = (Auth.auth().currentUser?.email ?? ""), postedOn: Date = Date()) {
        self.id = id
        self.imageURLString = imageURLString
        self.description = description
        self.reviewer = reviewer
        self.postedOn = postedOn
    }
}

extension Photo {
    static var preview: Photo {
        let newPhoto = Photo(
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Pizza-3007395.jpg/960px-Pizza-3007395.jpg",
            description: "Yummy Pizza",
            reviewer: "little@ceasers.com",
            postedOn: Date()
        )
        return newPhoto
    }
}
