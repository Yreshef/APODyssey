//
//  PictureRepository.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import UIKit

protocol PictureRepository {
    func loadPicture(for date: Date) async throws -> PictureOfTheDay
    func loadPictures(from startDate: Date, to endDate: Date) async throws -> [PictureOfTheDay]
    func loadImage(for picture: PictureOfTheDay) async throws -> Data
    func loadHD(for picture: PictureOfTheDay) async throws -> Data
    func cancelHD(for picture: PictureOfTheDay)
}


final class APODRepository: PictureRepository {
    
    private let apodService: APODServicing
    private let imageService: ImageServicing
    
    private var hdTasks: [String: Task<Data, Error>] = [:]
    
    init(service: APODServicing, imageService: ImageServicing) {
        self.apodService = service
        self.imageService = imageService
    }

    func loadPicture(for date: Date) async throws -> PictureOfTheDay {
        return try await apodService.fetch(for: date)
    }
    
    func loadPictures(from startDate: Date, to endDate: Date) async throws -> [PictureOfTheDay] {
        return try await apodService.fetchRange(from: startDate, to: endDate)
    }
    
    func loadImage(for picture: PictureOfTheDay) async throws -> Data {
        return try await imageService.fetchImageData(from: picture.imageURL)
    }
    
    func loadHD(for picture: PictureOfTheDay) async throws -> Data {
        let key = picture.id
        
        // If there’s already a task in-flight, await its result
        if let inFlight = hdTasks[key] {
            return try await inFlight.value
        }
        
        // Otherwise, create and store a new task
        let task = Task<Data, Error> {
            guard let hdURL = picture.hdImageURL else {
                throw APODError.network(.invalidURL)
            }
            return try await imageService.fetchImageData(from: hdURL)
        }
        
        hdTasks[key] = task
        
        do {
            return try await task.value
        } catch {
            // Clean up on failure
            hdTasks.removeValue(forKey: key)
            throw error
        }
    }
    
    func cancelHD(for picture: PictureOfTheDay) {
        hdTasks.removeValue(forKey: picture.id)?.cancel()
    }
}
