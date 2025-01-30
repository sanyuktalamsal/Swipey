//
//  PhotoLibraryViewModel.swift
//  Swipey
//
//  Created by Sanyukta Lamsal on 11/8/24.
//

import Foundation
import Photos
import SwiftUI

@MainActor
class PhotoLibraryViewModel: ObservableObject {
    @Published var photosToDelete: [PHAsset] = [] // Photos marked for deletion
    @Published var hasPhotoLibraryAccess: Bool = false
    @Published var photos: [Photo] = [] // Array of fetched photos
    @Published var currentIndex = 0 // Index of the current photo
    private let photoManager = PHPhotoLibrary.shared()

    let status = PHPhotoLibrary.authorizationStatus()

    // Request authorization and fetch all photos
    func requestAuthorizationAndFetchPhotos() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        if status == .authorized || status == .limited {
            hasPhotoLibraryAccess = true
            await fetchAllPhotos() // Fetch photos asynchronously
        } else {
            hasPhotoLibraryAccess = false
        }
    }

    // Fetch all photos in the library
    func fetchAllPhotos() {
        // Ensure permission is granted before fetching
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)

        // Map PHAssets to Photo objects
//         MainActor.run {
            photos = fetchResult.objects(at: IndexSet(0 ..< fetchResult.count)).map { Photo(asset: $0) }
//        }
    }

    // Mark the current photo for deletion
    func deletePhotoFolder() {
        guard !photos.isEmpty else { return }

        // Add the current photo to the deletion list
        if let asset = photos[currentIndex].asset {
            photosToDelete.append(asset)
        }

        // Remove the current photo from the photos array
        photos.remove(at: currentIndex)

        // Adjust the current index if the list is modified
        if photos.isEmpty {
            currentIndex = 0
        } else {
            currentIndex = currentIndex % photos.count
        }

        // Advance to the next photo
        advanceToNextPhoto()
    }

    // Permanently delete all marked photos
    func deletePhoto() {
        photoManager.performChanges({
            PHAssetChangeRequest.deleteAssets(self.photosToDelete as NSArray)
        }) { [weak self] success, _ in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    self.photosToDelete.removeAll()
                }
            }
        }
    }

    // Keep the current photo and move to the next one
    func keepPhoto() {
        guard !photos.isEmpty else { return }
        advanceToNextPhoto()
    }

    // Reevaluate the previous photo
    func reevaluatePhoto() {
        guard !photos.isEmpty else { return }
        currentIndex = (currentIndex - 1 + photos.count) % photos.count
    }

    // Advance to the next photo in the array
    func advanceToNextPhoto() {
        guard !photos.isEmpty else { return }
        currentIndex = (currentIndex + 1) % photos.count
    }
}
