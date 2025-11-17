//  ListView.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/1/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ListView: View {
    @FirestoreQuery(collectionPath: "spots") var spots: [Spot] // loads all "spots" document sinto the array variable named spots
    @State private var sheetIsPresented = false
    @State private var spotDetailIsPresented = false
    @State private var locationManager = LocationManager()
    @State private var newSpot = Spot() // To hold the spot being created
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(spots) { spot in
                NavigationLink {
                    SpotDetailView(spot: spot)
                } label: {
                    Text(spot.name)
                        .font(.title2)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        SpotViewModel.deleteSpot(spot: spot)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Snack Spots:")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("🪵➡️ Log out successful!")
                            dismiss()
                        } catch {
                            print("😡 ERROR: Could not sign out!")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
            .sheet(isPresented: $sheetIsPresented) {
                PlaceLookupView(locationManager: locationManager, spot: $newSpot)
                    .onDisappear {
                        // If a place was selected (spot has a name), present the detail view
                        if !newSpot.name.isEmpty {
                            spotDetailIsPresented = true
                        } else {
                            // Reset the spot if cancelled
                            newSpot = Spot()
                        }
                    }
            }
            .sheet(isPresented: $spotDetailIsPresented) {
                NavigationStack {
                    SpotDetailView(spot: newSpot)
                }
                .onDisappear {
                    //Reset the spot after detail view is dismissed
                    newSpot = Spot()
                }
            }
        }
    }
}

#Preview {
    ListView()
}
