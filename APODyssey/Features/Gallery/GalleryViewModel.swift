//
//  GalleryViewModel.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import Foundation
import Combine

@MainActor
final class GalleryViewModel: ErrorEmitting {

    let repository: PictureRepository
    let startDate: Date
    let endDate: Date

    @Published private(set) var pictures: [PictureOfTheDay] = []
    @Published private(set) var updatedThumbnailID: String?
    @Published private(set) var errorMessage: String?
    @Published var expandedIndexPath: IndexPath?
    @Published private(set) var isLoading: Bool = false
    
    var selectedIndex: Int?
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    private(set) var thumbnails: [String : Data] = [:]


    var onImageTapped: (([PictureOfTheDay], Int) -> Void)?

    init(
        repository: PictureRepository,
        startDate: Date,
        endDate: Date
    ) {
        self.repository = repository
        self.startDate = startDate
        self.endDate = endDate
    }

    func fetchPictures() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let results = try await repository.loadPictures(from: startDate, to: endDate)
                self.pictures = results
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadThumbnails(for picture: PictureOfTheDay) {
        guard self.thumbnails[picture.id] == nil else { return }

        Task.detached(priority: .utility) {
            do {
                let data = try await self.repository.loadImage(for: picture)
                
                await MainActor.run {
                    self.thumbnails[picture.id] = data
                    self.updatedThumbnailID = picture.id
                }
            } catch {
                //TODO: Assign placeholder or fail here
            }
        }
    }
    
    func toggleExpansion(at indexPath: IndexPath) {
        if expandedIndexPath == indexPath {
            expandedIndexPath = nil
        } else {
            expandedIndexPath = indexPath
        }
    }
    
    func isExpanded(_ indexPath: IndexPath) -> Bool {
        return expandedIndexPath == indexPath
    }
    
    func didSelectItem(_ index: Int) {
        onImageTapped?(pictures, index)
    }
}
