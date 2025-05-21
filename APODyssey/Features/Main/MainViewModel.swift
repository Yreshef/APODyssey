//
//  MainViewModel.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Foundation
import Combine

@MainActor
final class MainViewModel: ErrorEmitting {

    // MARK: - Outputs
    @Published private(set) var picture: PictureOfTheDay?
    @Published private(set) var image: Data?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    lazy var errorMessagePublisher: AnyPublisher<String?, Never> = {
        $errorMessage.eraseToAnyPublisher()
    }()

    // MARK: - Coordinator Callback
    var onDateRangeSelected: ((Date, Date) -> Void)?
    var onDateSelected: ((Date) -> Void)?

    // MARK: - Dependencies
    private let repository: PictureRepository
    private var loadTask: Task<Void, Never>?

    // MARK: - Init
    init(repository: PictureRepository) {
        self.repository = repository
    }

    // MARK: - Public API

    func loadToday() {
        load(for: NASADateProvider.today)
    }

    func load(for date: Date) {
        isLoading = true
        errorMessage = nil
        image = nil
        picture = nil
        loadTask?.cancel()

        loadTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                let pic = try await repository.loadPicture(for: date)
                let imageData = try await repository.loadImage(for: pic)

                self.picture = pic
                self.image = imageData
            } catch {
                self.errorMessage = error.localizedDescription
            }

            self.isLoading = false
        }
    }

    func cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
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
}
