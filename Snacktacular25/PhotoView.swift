//  PhotoView.swift
//  Snacktacular25
//  Created by John Gallaugher on 11/2/25.
//  YouTube.com/profgallaugher - gallaugher.bsky.social

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State var spot: Spot // passed from the SpotDetailView
    @State private var photo = Photo()
    @State private var data = Data() // We need to take image & convert it to data to save it to FirebaseStorage
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pickerIsPresented = true // TODO: Switch to true
    @State private var selectedImage = Image(systemName: "photo")
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            
            Spacer()
            
            selectedImage
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            TextField("description", text: $photo.description)
                .textFieldStyle(.roundedBorder)
            
            Text("by: \(photo.reviewer), on: \(photo.postedOn.formatted(date: .numeric, time: .omitted))")
            
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", systemImage: "checkmark") {
                            Task {
                                await PhotoViewModel.saveImage(spot: spot, photo: photo, data: data)
                                dismiss()
                            }
                        }
                    }
                }
                .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhoto)
                .onChange(of: selectedPhoto) {
                    // turn selectedPhoto into a usable Image View
                    Task {
                        do {
                            if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
                                selectedImage = image
                            }
                            // Get raw data from image so we can save it to Firebase Storage
                            guard let transferredData = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                                print("😡 ERROR: Could not convert data from selectedPhoto.")
                                return
                            }
                            data = transferredData
                        } catch {
                            print("😡 ERROR: Could not create Image ferom selectedPhoto. \(error.localizedDescription)")
                        }
                    }
                }
        }
        .padding()
    }
}

#Preview {
    PhotoView(spot: Spot())
}
