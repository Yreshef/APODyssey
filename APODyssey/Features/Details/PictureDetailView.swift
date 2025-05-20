//
//  PictureDetailView.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import SwiftUI

struct PictureDetailView: View {
    @ObservedObject var viewModel: PictureDetailViewModel
    @State var showInfoSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            contentView
        }
        .sheet(isPresented: $showInfoSheet, content: {
            if let picture = viewModel.picture {
                PictureDetailInfoSheet(picture: picture)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        })
        .onDisappear() {
            print("Details deinit")
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("Loading...")
                .foregroundColor(.white)
        } else if let picture = viewModel.picture {
            PictureContentView(picture: picture, showInfoSheet: $showInfoSheet)
        } else {
            EmptyView()
        }
    }
    //TODO: Implement errors in view model
    private func errorView(message: Error) -> some View {
        Text("Error: \(message)")
            .foregroundColor(.red)
            .padding()
    }
}



//#Preview {
//    PictureDetailView(viewModel: PictureDetailViewModel(picture: PictureOfTheDay.mock))
//}
//TODO: Move mocks to previewMocks folder
extension PictureOfTheDay {
    static var mock: PictureOfTheDay {
            PictureOfTheDay(
                date: "2025-05-19",
                title: "The Pillars of Creation",
                explanation: "This famous image of interstellar gas and dust pillars is part of the Eagle Nebula, where new stars are born.",
                copyright: "NASA/ESA",
                imageURL: URL(string: "https://example.com/image.jpg")!,
                hdImageURL: URL(string: "https://example.com/hd-image.jpg"),
                image: UIImage(systemName: "photo")!,
                hash1: "abc123def456",
                hash2: "789ghi012jkl",
                thumbnail100: UIImage(systemName: "photo.fill"),
                thumbnail300: UIImage(systemName: "photo.fill"),
                thumbnail300Hash: "thumbhash300xyz"
            )
        }
}
