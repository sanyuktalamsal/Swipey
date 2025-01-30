//
//  PhotoLibraryRequestView.swift
//  Swipey
//
//  Created by Sanyukta Lamsal on 11/13/24.
//

import SwiftUI

struct PhotoLibraryRequestView: View {
    @ObservedObject var vm = PhotoLibraryViewModel()

    var body: some View {
        Group {
            if vm.status == .notDetermined {
                VStack(spacing: 20) {
                    Spacer()

                    // App Title with Icon
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)

                        Text("Swipey")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }

                    // Information Text
                    Text("Swipey uses your Photo library to help you manage your photos, videos, live pictures, and more!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    Spacer()

                    // Access Button
                    Button(action: {
                        Task {
                            await vm.requestAuthorizationAndFetchPhotos()
                        }
                    }) {
                        Text("Allow Access")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()

            } else if vm.status == .authorized || vm.status == .limited {
                PhotoView(viewModel: vm)
            } else {
                VStack(spacing: 20) {
                    Spacer()

                    // Denied Access Icon and Message
                    Image(systemName: "lock.shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)

                    Text("Access Denied")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Photo Library access is denied. Please enable access in settings.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    Spacer()

                    // Suggestion to Go to Settings
                    Button(action: {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text("Open Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .red.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
        }
        .animation(.easeInOut, value: vm.status)
    }
}

#Preview {
    PhotoLibraryRequestView()
}
