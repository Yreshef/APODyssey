//
//  MainViewModel.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import Foundation

final class MainViewModel: ErrorEmitting {

    // MARK: - Outputs
    @Published private(set) var picture: PictureOfTheDay?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    // MARK: - Coordinator Callback
    var onDateRangeSelected: ((Date, Date) -> Void)?
    var onDateSelected: ((Date) -> Void)?

    // MARK: - Dependencies
    private let repository: PictureRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(repository: PictureRepository) {
        self.repository = repository
    }

    func handleUserDateSelection(_ components: [DateComponents]) {
        let dates =
            components
            .compactMap { Calendar.current.date(from: $0) }
            .sorted()

        switch dates.count {
        case 1: onDateSelected?(dates[0])
        case 2: onDateRangeSelected?(dates[0], dates[1])
        default: errorMessage = "invalid selection"
        }
    }

    // MARK: - Public API

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
