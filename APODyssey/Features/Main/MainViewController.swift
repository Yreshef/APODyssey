//
//  MainViewController.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    private let viewModel: MainViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

