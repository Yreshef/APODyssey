//
//  ErrorAlertController.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import UIKit
import Combine

protocol ErrorEmitting: AnyObject {
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
}

final class ErrorAlertController {
    private var cancellable: AnyCancellable?

      init(
          errorMessages: AnyPublisher<String?, Never>,
          in viewController: UIViewController
      ) {
          cancellable = errorMessages
              .compactMap { $0 } // skip nils
              .receive(on: DispatchQueue.main)
              .sink { message in
                  let alert = UIAlertController(
                      title: "Error",
                      message: message,
                      preferredStyle: .alert
                  )
                  alert.addAction(.init(title: "OK", style: .default))
                  viewController.present(alert, animated: true)
              }
      }
}
