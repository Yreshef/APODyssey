//
//  PictureRepository.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import UIKit

protocol PictureRepository {
    func fetchPicture(for date: Date) -> AnyPublisher<
        PictureOfTheDay, PictureRepositoryError
    >
    func fetchRange(start: Date, end: Date) -> AnyPublisher<
        [PictureOfTheDay], PictureRepositoryError
    >
}

enum PictureRepositoryError: Error {
    case apod(APODError)
    case image(ImageServiceError)
    case mediaTypeUnsupported
    case unknown(Error)
}

final class APODRepository: PictureRepository {

    private let apodService: APODServicing
    private let imageService: ImageServicing

    init(
        apodService: APODServicing,
        imageService: ImageServicing
    ) {
        self.apodService = apodService
        self.imageService = imageService
    }

    func fetchPicture(for date: Date) -> AnyPublisher<
        PictureOfTheDay, PictureRepositoryError
    > {
        apodService.fetch(date: date)
            .mapError { PictureRepositoryError.apod($0) }
            .flatMap(maxPublishers: .max(1)) {
                response -> AnyPublisher<
                    PictureOfTheDay, PictureRepositoryError
                > in
                guard
                    response.mediaType == "image",
                    let imageURL = URL(string: response.url)
                else {
                    return Fail(
                        error: PictureRepositoryError.mediaTypeUnsupported
                    )
                    .eraseToAnyPublisher()
                }

                return self.imageService.fetchImage(from: imageURL)
                    .mapError { PictureRepositoryError.image($0) }
                    .map { fetchedImage in
                        PictureOfTheDay(
                            date: response.date,
                            title: response.title,
                            explanation: response.explanation,
                            copyright: response.copyright,
                            imageURL: imageURL,
                            hdImageURL: response.hdurl.flatMap(URL.init),
                            image: fetchedImage.image,
                            hash1: fetchedImage.hash1,
                            hash2: fetchedImage.hash2,
                            thumbnail100: nil,
                            thumbnail300: nil,
                            thumbnail300Hash: nil
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchRange(start: Date, end: Date) -> AnyPublisher<
        [PictureOfTheDay], PictureRepositoryError
    > {
        apodService.fetchRange(start: start, end: end)
            .mapError { PictureRepositoryError.apod($0) }
            .flatMap {
                responses -> AnyPublisher<
                    [PictureOfTheDay], PictureRepositoryError
                > in
                let validResponses = responses.filter {
                    $0.mediaType == "image" && URL(string: $0.url) != nil
                }

                let publishers = validResponses.map {
                    response -> AnyPublisher<PictureOfTheDay, Never> in
                    guard let imageURL = URL(string: response.url) else {
                        return Empty().eraseToAnyPublisher()
                    }

                    return self.imageService.fetchImage(from: imageURL)
                        .map { fetchedImage in
                            
                            PictureOfTheDay(
                                date: response.date,
                                title: response.title,
                                explanation: response.explanation,
                                copyright: response.copyright,
                                imageURL: imageURL,
                                hdImageURL: response.hdurl.flatMap(URL.init),
                                image: fetchedImage.image,
                                hash1: fetchedImage.hash1,
                                hash2: fetchedImage.hash2,
                                thumbnail100: fetchedImage.image.resized(to: CGSize(width: 100, height: 100)),
                                thumbnail300: fetchedImage.thumbnail300,
                                thumbnail300Hash: fetchedImage.thumbnailHash
                            )
                        }
                        .catch { _ in Empty() }  // suppress individual errors
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .setFailureType(to: PictureRepositoryError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func mapAPODError(_ error: Error) -> PictureRepositoryError {
        if let apodError = error as? APODError {
            return .apod(apodError)
        } else if let repoError = error as? PictureRepositoryError {
            return repoError
        } else {
            return .unknown(error)
        }
    }

}
