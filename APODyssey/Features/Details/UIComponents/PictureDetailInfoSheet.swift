//
//  PictureDetailInfoSheet.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import SwiftUI

struct PictureDetailInfoSheet: View {
    let picture: PictureOfTheDay

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(picture.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                if let copyright = picture.copyright {
                    Text("© \(copyright)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hash 1:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(picture.hash1)
                        .font(.body)
                        .textSelection(.enabled)

                    Text("Hash 2:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    Text(picture.hash2)
                        .font(.body)
                        .textSelection(.enabled)
                }

                Divider()

                Text("Explanation")
                    .font(.headline)
                    .padding(.bottom, 4)

                Text(picture.explanation)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Date: \(picture.date)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .padding()
        }
    }
}

//TODO: Add placeholder mocks
//#Preview {
//    PictureDetailInfoSheet()
//}
