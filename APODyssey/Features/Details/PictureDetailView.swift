//
//  PictureDetailView.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import SwiftUI

struct PictureDetailView: View {
    @ObservedObject var viewModel: PictureDetailViewModel
    @State private var showInfoSheet: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            content
        }
        .onDisappear {
            viewModel.onDismiss?(viewModel.currentIndex)
        }
    
        .sheet(isPresented: $showInfoSheet) {
            if let picture = viewModel.picture {
                PictureDetailInfoSheet(picture: picture)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch currentState {
        case .loading:
            ProgressView("Loading...")
                .foregroundColor(.white)
                .padding()

        case .loaded(let picture, let imageData):
            PictureContentView(
                picture: picture,
                showInfoSheet: $showInfoSheet,
                imageData: imageData
            )
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            viewModel.goToNext()
                        } else if value.translation.width > 50 {
                            viewModel.goToPrevious()
                        }
                    }
            )
            .animation(.easeInOut, value: viewModel.currentIndex)
            .transition(.slide)

        case .error(let message):
            VStack(spacing: 12) {
                Text("🚫 Error")
                    .font(.title2)
                    .foregroundColor(.red)
                Text(message)
                    .foregroundColor(.white)
                Button("Retry") {
                    viewModel.retry()
                }
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(Capsule())
            }
        }
    }

    private var currentState: DetailState {
        if let error = viewModel.errorMessage {
            return .error(error)
        }

        guard let picture = viewModel.picture else {
            return .loading
        }

        return .loaded(picture, viewModel.imageData)
    }

    private enum DetailState {
        case loading
        case loaded(PictureOfTheDay, Data?)
        case error(String)
    }
}




//#Preview {
//    PictureDetailView(viewModel: PictureDetailViewModel(picture: PictureOfTheDay.mock))
//}
////TODO: Move mocks to previewMocks folder
//extension PictureOfTheDay {
//    static var mock: PictureOfTheDay {
//            PictureOfTheDay(
//                date: "2025-05-19",
//                title: "The Pillars of Creation",
//                explanation: "This famous image of interstellar gas and dust pillars is part of the Eagle Nebula, where new stars are born.",
//                copyright: "NASA/ESA",
//                imageURL: URL(string: "https://example.com/image.jpg")!,
//                hdImageURL: URL(string: "https://example.com/hd-image.jpg"),
//                image: UIImage(systemName: "photo")!,
//                hash1: "abc123def456",
//                hash2: "789ghi012jkl",
//                thumbnail100: UIImage(systemName: "photo.fill"),
//                thumbnail300: UIImage(systemName: "photo.fill"),
//                thumbnail300Hash: "thumbhash300xyz"
//            )
//        }
//}
