//  SpotDetailView.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import SwiftUI
import Firebase
import FirebaseFirestore

struct SpotDetailView: View {
    @FirestoreQuery(collectionPath: "spots") var fsPhotos: [Photo]
    @State var spot: Spot // pass in value from ListView
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false // Alert user if they need to sve Spot berfore adding a Photo
    private let alertMessage = "Cannot add a photo until you save a Spot."
    @Environment(\.dismiss) private var dismiss
    private var photos: [Photo] {
        // If running in Preview then show mock data
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return [Photo.preview, Photo.preview, Photo.preview, Photo.preview, Photo.preview, Photo.preview]
        }
        // else show Firebase Data
        return fsPhotos
    }
    
    var body: some View {
        VStack {
            Group {
                TextField("name", text: $spot.name)
                    .font(.title)
                    .autocorrectionDisabled()
                TextField("address", text: $spot.address)
                    .font(.title2)
                    .autocorrectionDisabled()
            }
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .padding(.horizontal)
            
            Text("Lat: \(spot.latitude), Long: \(spot.longitude)")
            
            Button { // Photo Button
                if spot.id == nil { // Ask if you want to save
                    showingAlert.toggle()
                } else {
                    photoSheetIsPresented.toggle() // opens full screen view that presents photo view
                }
            } label: {
                Image(systemName: "camera.fill")
                Text("Photo")
            }
            .bold()
            .buttonStyle(.borderedProminent)
            .tint(.snack)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photos) { photo in
                        let url = URL(string: photo.imageURLString)
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            .frame(height: 80)
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .task {
            guard let id = spot.id else {
                print("New record - has no id")
                return
            }
            $fsPhotos.path = "spots/\(id)/photos"
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    saveSpot()
                    dismiss()
                }
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                // We want to return spot.id after savign a new Spot. Right now it's nil
                Task {
                    guard let id = await SpotViewModel.saveSpot(spot: spot) else {
                        print("😡 ERROR: Saving spot in alert returned nil")
                        return
                    }
                    spot.id = id
                    print("spot.id: \(id)")
                    $fsPhotos.path = "spots/\(id)/photos" // Now that we've saved the spot, we have an id, so we can get the photos
                    photoSheetIsPresented.toggle() // Now open sheet & move to the PhotoView
                }
            }
        }
        .fullScreenCover(isPresented: $photoSheetIsPresented) {
            PhotoView(spot: spot)
        }
    }
    
    func saveSpot() {
        Task {
            guard let id = await SpotViewModel.saveSpot(spot: spot) else {
                print("😡 ERROR: Saving spot from Save button")
                return
            }
            print("spot.id: \(id)")
            print("😎 Nice Spot save!")
        }
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: Spot.preview)
    }
}
