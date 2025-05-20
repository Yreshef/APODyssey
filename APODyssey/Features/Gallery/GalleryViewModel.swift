//
//  GalleryViewModel.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import Combine
import Foundation

final class GalleryViewModel: ErrorEmitting {

    let repository: PictureRepository
    let startDate: Date
    let endDate: Date

    @Published private(set) var items: [PictureOfTheDay] = []
    @Published private(set) var errorMessage: String?
 
    var onImageTapped: ((PictureOfTheDay) -> Void)?

    private var cancellables = Set<AnyCancellable>()
    
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }


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
        repository.fetchPictures(from: startDate, to: endDate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] picture in
                self?.items.append(picture)
            }
            .store(in: &cancellables)
    }
    
    func didSelectItem(_ item: PictureOfTheDay) {
        onImageTapped?(item)
    }
}
