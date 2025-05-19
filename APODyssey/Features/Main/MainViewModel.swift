//
//  MainViewModel.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import Foundation

final class MainViewModel {

    // MARK: - Outputs
    @Published private(set) var picture: PictureOfTheDay?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Inputs
    let selectDateOrRange = PassthroughSubject<Void, Never>()

    // MARK: - Coordinator Callback
    var onSelectDateOrRange: (() -> Void)?

    // MARK: - Dependencies
    private let repository: PictureRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(repository: PictureRepository) {
        self.repository = repository
        bindSelectAction()
    }

    // MARK: - Private Methods
    private func bindSelectAction() {
        selectDateOrRange
            .sink { [weak self] in
                self?.onSelectDateOrRange?()
            }
            .store(in: &cancellables)
    }
    
    func handleUserDateSelection(_ components: [DateComponents]) {
        let dates = components
            .compactMap { Calendar.current.date(from: $0) }
            .sorted()
        
        switch dates.count {
        case 1: fetchSingleDateImage(for: dates[0])
        case 2: fetchRange(start: dates[0], end: dates[1])
        default: errorMessage = "invalid selection"
        }
    }
    
    private func fetchSingleDateImage(for date: Date) {
        print("fetching single image")
    }
    
    private func fetchRange(start: Date, end: Date) {
        print("fetching multiple images")
    }

    // MARK: - Public API
    func loadWorkingImage() {
        isLoading = true
        errorMessage = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let lastImageDay = formatter.date(from: "2025-05-17") {
            repository.fetchPicture(for: lastImageDay)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    if case let .failure(error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] picture in
                    self?.picture = picture
                }
                .store(in: &cancellables)
        }
    }

    func loadToday() {
        isLoading = true
        errorMessage = nil

        repository.fetchPicture(for: Date())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] picture in
                self?.picture = picture
            }
            .store(in: &cancellables)
    }
    
    func load(date: Date) {
        isLoading = true
        errorMessage = nil
        repository.fetchPicture(for: date)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] pic in
                self?.picture = pic
            }
            .store(in: &cancellables)
    }
}
