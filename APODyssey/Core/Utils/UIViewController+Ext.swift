//
//  UIViewController+Ext.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import UIKit
import Combine

extension UIViewController {
    @discardableResult
    func bindErrorAlert(to viewController: UIViewController,
        from publisher: AnyPublisher<String?, Never>
    ) -> ErrorAlertController {
        ErrorAlertController(errorMessages: publisher, in: viewController)
    }
}
