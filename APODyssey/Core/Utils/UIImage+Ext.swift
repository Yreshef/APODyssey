//
//  UIImage+Ext.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

extension UIImage {
    
    /// Resizes the image to a fixed size, used for 100x100 and 300x300 thumbnails in the APOD UI.
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func hash(using hasher: ImageHashing) -> String? {
        guard let data = self.pngData() else { return nil }
        return hasher.hash(data: data)
    }
}
