////
////  EditSessionView.swift
////  Swiper
////
////  Created by Sanyukta Lamsal on 12/2/24.
////
//
//import SwiftUI
//import Photos
//
//struct EditSessionView: View {
//    @ObservedObject var viewModel: PhotoLibraryViewModel
//
//    let columns = [
//        GridItem(.flexible()),
//        GridItem(.flexible())
//    ]
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if viewModel.photosToDelete.isEmpty {
//                    Text("No photos marked for deletion.")
//                        .font(.title2)
//                        .padding()
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 20) {
//                            ForEach(viewModel.photosToDelete, id: \.self) { photo in
//                                if let asset = photo.asset {
//                                    PhotoThumbnailView(asset: asset)
//                                        .frame(height: 150)
//                                        .cornerRadius(10)
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                }
//
//                Spacer()
//
//                Button(action: {
//                    viewModel.clearPhotosToDelete()
//                }) {
//                    Text("Clear All Marked Photos")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                }
//                .padding()
//                .disabled(viewModel.photosToDelete.isEmpty)
//            }
//            .navigationTitle("Edit Session")
//        }
//    }
//}
//
//struct PhotoThumbnailView: View {
//    let asset: PHAsset
//
//    var body: some View {
//        ImageLoader(asset: asset)
//            .aspectRatio(contentMode: .fill)
//            .clipped()
//    }
//}
//
//struct ImageLoader: View {
//    let asset: PHAsset
//    @State private var image: UIImage?
//
//    var body: some View {
//        if let image = image {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//        } else {
//            ProgressView()
//                .onAppear {
//                    loadThumbnail()
//                }
//        }
//    }
//
//    private func loadThumbnail() {
//        let imageManager = PHImageManager.default()
//        let options = PHImageRequestOptions()
//        options.version = .current
//        options.deliveryMode = .highQualityFormat
//        options.isSynchronous = false
//
//        imageManager.requestImage(
//            for: asset,
//            targetSize: CGSize(width: 150, height: 150),
//            contentMode: .aspectFill,
//            options: options
//        ) { image, _ in
//            DispatchQueue.main.async {
//                self.image = image
//            }
//        }
//    }
//}
//
//#Preview {
//    EditSessionView()
//}
