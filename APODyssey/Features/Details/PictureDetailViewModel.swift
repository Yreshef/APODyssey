//
//  PictureDetailViewModel.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import Combine
import Foundation

@MainActor
final class PictureDetailViewModel: ObservableObject {

    @Published var currentIndex: Int = 0
    @Published private(set) var pictures: [PictureOfTheDay] = []
    @Published private(set) var imageData: Data?
    @Published var errorMessage: String?
    @Published var showInfoSheet: Bool = false
    
    var onDismiss: ((Int) -> Void)?

    var picture: PictureOfTheDay? {
        pictures[safe: currentIndex]
    }
    
    private let repository: PictureRepository
    
    init(repository: PictureRepository, pictures: [PictureOfTheDay],initialIndex: Int) {
        self.repository = repository
        self.pictures = pictures
        self.currentIndex = initialIndex
        loadHDImageForCurrent()
    }

    init(repository: PictureRepository, date: Date) {
        self.repository = repository
        Task {
            await loadSinglePicture(from: date)
        }
        loadHDImageForCurrent()
    }

    func goToNext() {
        guard !pictures.isEmpty else { return }
        currentIndex = (currentIndex + 1) % pictures.count
        loadHDImageForCurrent()
    }

    func goToPrevious() {
        guard !pictures.isEmpty else { return }
        currentIndex = (currentIndex - 1 + pictures.count) % pictures.count
        loadHDImageForCurrent()
    }
    
    func retry() {
        if let date = pictures.first?.date, pictures.count == 1 {
            // Single-picture mode (from date)
            Task {
                await loadSinglePicture(from: date.toDate() ?? Date())
            }
        } else {
            // Multi-picture mode
            loadHDImageForCurrent()
        }
    }
    
    private func loadSinglePicture(from date: Date) async {
        do {
            let picture = try await repository.loadPicture(for: date)
            self.pictures = [picture]
            self.currentIndex = 0
            loadHDImageForCurrent()
        } catch {
            self.pictures = []
            self.imageData = nil
            self.errorMessage = error.localizedDescription
        }
    }

    func loadHDImageForCurrent() {
       guard let picture = picture else {
           self.imageData = nil
           return
       }
        
        Task {
            do {
                let data = try await repository.loadHD(for: picture)
                self.imageData = data
            } catch {
                self.imageData = nil
                self.errorMessage = error.localizedDescription
            }
        }
        preloadAdjecantHDs(range: 2)
    }
    
    private func preloadAdjecantHDs(range: Int) {
        let indicesToPreload = Array((currentIndex - range)...(currentIndex + range))
              .filter { $0 != currentIndex && pictures.indices.contains($0) }
        for index in indicesToPreload {
            let pic = pictures[index]
            Task.detached(priority: .background) {
                _ = try? await self.repository.loadHD(for: pic)
            }
        }
    }
    
    
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
