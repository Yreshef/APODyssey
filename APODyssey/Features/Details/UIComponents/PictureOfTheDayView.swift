//
//  PictureOfTheDayView.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import SwiftUI

struct PictureContentView: View {
    let picture: PictureOfTheDay
    @Binding var showInfoSheet: Bool

    var body: some View {
        VStack {
            if let url = picture.hdImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            Button("Show Info") {
                showInfoSheet = true
            }
            .font(.headline)
            .padding()
            .background(.ultraThickMaterial)
            .clipShape(Capsule())
            .padding(.bottom)
        }
        .padding()
    }
}
    
//TODO: Add placeholder mocks
//#Preview {
//    PictureOfTheDayView(pictureURL: <#URL#>)
//}
