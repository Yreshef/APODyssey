//
//  PictureDetailViewModel.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import Foundation
import Combine

final class PictureDetailViewModel: ObservableObject {
    
    @Published var picture: PictureOfTheDay?
    @Published var isLoading: Bool = false
    @Published var showInfoSheet: Bool = false
    
    private let repository: PictureRepository
    private let targetDate: Date?
    private var cancellables: Set<AnyCancellable> = []
    
    init( repository: PictureRepository, initialPicture: PictureOfTheDay? = nil, date: Date? = nil) {
        self.repository = repository
        self.picture = initialPicture
        self.targetDate = date
        
        if initialPicture == nil, let date = targetDate {
            fetchPicture(for: date)
        }
    }
    
    private func fetchPicture(for date: Date) {
        isLoading = true
        repository.fetchPicture(for: date)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    
                }
            } receiveValue: { [weak self] picture in
                self?.picture = picture
            }
            .store(in: &cancellables)
    }
}
