//  SpotViewModel.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import Foundation
import FirebaseFirestore

@Observable
class SpotViewModel {
    
    static func saveSpot(spot: Spot) async -> String? {
        let db = Firestore.firestore()
        
        if let id = spot.id { // spot must already exist, so save
            do {
                try db.collection("spots").document(id).setData(from: spot)
                print("😎 Data updated successfully!")
                return id
            } catch {
                print("😡 ERROR: Could not save data in 'spots' \(error.localizedDescription)")
                return id
            }
        } else { // no id? Then we need to add a new spot & create a new id / document name
            do {
                let docRef = try db.collection("spots").addDocument(from: spot)
                print("🐣 Data added successfully!")
                return docRef.documentID
            } catch {
                print("😡 ERROR: Could not create a new spot in 'spots' \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteSpot(spot: Spot) {
        let db = Firestore.firestore()
        
        guard let id = spot.id else {
            print("No spot.id")
            return
        }
        
        Task {
            do {
                try await db.collection("spots").document(id).delete()
            } catch {
                print("😡 ERROR: Could not delete document \(id). \(error.localizedDescription)")
            }
        }
    }
}
