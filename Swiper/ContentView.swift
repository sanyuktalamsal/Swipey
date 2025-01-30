//
//  ContentView.swift
//  Swipey
//
//  Created by Sanyukta Lamsal on 11/8/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = PhotoLibraryViewModel()

    var body: some View {
        Group {
            if viewModel.hasPhotoLibraryAccess == false {
                PhotoLibraryRequestView(vm: viewModel)
            } else {
                PhotoView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
