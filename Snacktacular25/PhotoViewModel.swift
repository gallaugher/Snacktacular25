//  PhotoViewModel.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI
import FirebaseFirestore

class PhotoViewModel {
    
    static func saveImage(spot: Spot, photo: Photo, data: Data) async {
        guard let id = spot.id else {
            print("😡 ERROR: Should never have been called without a valid spot.id")
            return
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        if photo.id == nil {
            photo.id = UUID().uuidString // create a unique filename for the photo about to be saved
        }
        metadata.contentType = "image/jpeg" // will allow image to be viewed in the browser from the Firebase console
        let path = "\(id)/\(photo.id ?? "n/a")" // id is the name of the Spot document (spot.id). All photos for a spot will be saved in a "folder" with its spot document name.
        
        do {
            let storageRef = storage.child(path)
            let returnedMetaData = try await storageRef.putDataAsync(data, metadata: metadata)
            print("😎 SAVED! \(returnedMetaData)")
            
            // get URL that we'll use to load the image
            guard let url = try? await storageRef.downloadURL() else {
                print("😡 ERROR Could not get downloadURL.")
                return
            }
            photo.imageURLString = url.absoluteString
            print("photo.imageURLString: \(photo.imageURLString)")
            
            // Now that photo file is saved to Storage, save a Photo document to the spot.id's "Photos" collection
            let db = Firestore.firestore()
            do {
                try db.collection("spots").document(id).collection("photos").document(photo.id ?? "n/a").setData(from: photo)
            } catch {
                print("😡 ERROR could not update data in spots/\(id)/photos/\(photo.id ?? "n/a"). \(error.localizedDescription)")
            }
        } catch {
            print("😡 ERROR saving photo to Storage \(error.localizedDescription)")
        }
    }
}
