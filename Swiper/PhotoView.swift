//
//  PhotoView.swift
//  Swipey
//
//  Created by Sanyukta Lamsal on 11/8/24.
//

import Photos
import SwiftUI

struct PhotoView: View {
    @ObservedObject var viewModel: PhotoLibraryViewModel
    @State private var showAlert = false
    @State private var currentImage: UIImage?
    @State private var dragOffset: CGSize = .zero
    @State private var backgroundColor: Color = .clear
    @State private var actionTriggered: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.photos.isEmpty {
                    // Display the current photo with swipe gesture
                    if viewModel.photos[viewModel.currentIndex].asset != nil {
                        if let image = currentImage {
                            ZStack {
                                backgroundColor
                                    .edgesIgnoringSafeArea(.all)
                                    .animation(.easeInOut, value: backgroundColor)

                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(
                                        width: UIScreen.main.bounds.width * 0.9, // 90% of screen width
                                        height: UIScreen.main.bounds.height * 0.7 // 70% of screen height
                                    )
                                    .cornerRadius(20)
                                    .offset(x: dragOffset.width)
                                    .opacity(1.0 - Double(abs(dragOffset.width) / 300))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                if !actionTriggered {
                                                    dragOffset = gesture.translation
                                                    backgroundColor = dragOffset.width > 0 ? .green.opacity(0.5) : .red.opacity(0.5)
                                                }
                                            }
                                            .onEnded { _ in
                                                handleSwipe()
                                            }
                                    )
                                    .animation(.spring(), value: dragOffset)

                            }

                        } else {
                            ProgressView()
                                .frame(width: 300, height: 300)
                        }
                    } else {
                        Text("Unable to load photo.")
                            .padding()
                            .font(.headline)
                    }

                    Spacer()

                    HStack {
                        Button(action: {
                            viewModel.reevaluatePhoto()
                        }) {
                            Image(systemName: "arrow.uturn.left")
                                .font(.title)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.photos.isEmpty)

                        Spacer()

                        Button(action: {
                            triggerSwipeAnimation(direction: .left)
                        }) {
                            Image(systemName: "trash")
                                .font(.title)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.photos.isEmpty)

                        Spacer()

                        Button(action: {
                            triggerSwipeAnimation(direction: .right)
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.photos.isEmpty)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 20)
                } else {
                    Text("No photos available.")
                        .font(.title2)
                        .padding()
                    Button(action: {
                        Task {
                            viewModel.fetchAllPhotos()
                        }
                    }) {
                        Text("Import Photos")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing:
                Button("End Session") {
                    showAlert = true
                }
            )
            .alert("End Session", isPresented: $showAlert) {
                Button("Delete Marked Photos", role: .destructive) {
                    viewModel.deletePhoto()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Do you want to delete all the photos you marked for deletion?")
            }
            .onAppear(perform: loadCurrentPhoto)
            .onChange(of: viewModel.currentIndex) { _ in
                loadCurrentPhoto()
            }
        }
    }
    
    private func triggerSwipeAnimation(direction: SwipeDirection) {
        // Update dragOffset and backgroundColor based on the swipe direction
        withAnimation {
            dragOffset.width = direction == .right ? 600 : -600
            backgroundColor = direction == .right ? .green.opacity(0.5) : .red.opacity(0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            handleSwipe()
        }
    }


    enum SwipeDirection {
        case left, right
    }


    private func handleSwipe() {
        guard !viewModel.photos.isEmpty else { return }

        if dragOffset.width < -100   {
            // Swipe left: Delete photo
            actionTriggered = true
            withAnimation {
                dragOffset.width = -600
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.deletePhotoFolder()
                resetSwipe()
            }
        }else if dragOffset.width > 100 {
            // Swipe right: Keep photo
            actionTriggered = true
            withAnimation {
                dragOffset.width = 600
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.keepPhoto()
                resetSwipe()
            }
        } else {
            resetSwipe()
        }
    }

    private func resetSwipe() {
        withAnimation {
            dragOffset = .zero
            backgroundColor = .clear
            actionTriggered = false
        }
    }

    private func loadCurrentPhoto() {
        guard !viewModel.photos.isEmpty,
              let asset = viewModel.photos[viewModel.currentIndex].asset else {
            currentImage = nil
            return
        }

        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact  // Avoid unnecessary resizing
        options.isSynchronous = false

        // Calculate target size based on screen dimensions
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width * 1.2, // Larger than display to ensure quality
            height: UIScreen.main.bounds.height * 1.2
        )

        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.currentImage = image
            }
        }
    }

}

#Preview {
    PhotoView(viewModel: PhotoLibraryViewModel())
}
