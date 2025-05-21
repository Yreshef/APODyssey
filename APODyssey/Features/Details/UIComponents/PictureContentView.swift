//
//  PictureContentView.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import SwiftUI

struct PictureContentView: View {
    let picture: PictureOfTheDay
    @Binding var showInfoSheet: Bool
    let imageData: Data?

    @State private var displayedImage: UIImage?

    var body: some View {
        VStack {
            ZStack {
                if let image = displayedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .transition(.opacity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.25), value: displayedImage)

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
        .onChange(of: imageData) { _, newData in
            if let newData, let uiImage = UIImage(data: newData) {
                self.displayedImage = uiImage
            } else {
                self.displayedImage = nil
            }
        }
    }
}



//TODO: Add placeholder mocks
//#Preview {
//    PictureOfTheDayView(pictureURL: <#URL#>)
//}
