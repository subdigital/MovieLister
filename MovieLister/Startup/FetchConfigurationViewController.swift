//
//  FetchConfigurationViewController.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/9/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit
import SimpleNetworking

class FetchConfigurationViewController : UIViewController {
    
    private let label = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let stackView = UIStackView()
    
    let completionBlock: (() -> Void)
    
    init(completionBlock: @escaping () -> Void) {
        self.completionBlock = completionBlock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConfiguration()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .secondarySystemBackground
        
        label.text = "Please wait while we initialize the app..."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(activityIndicator)
        
        view.addSubview(stackView)
        
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    
    private func updateConfiguration() {
        activityIndicator.startAnimating()


        MovieDB.api.send(request: .configuration({ (result) in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let config):
                MovieDBConfiguration.current = config
                self.completionBlock()
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }))
    }
    
    private func showError(error: Error) {
        
        let message: String
        if let apiError = error as? APIError {
            if case .requestError(let statusCode) = apiError, statusCode == 401 {
                message = "Unauthorized. Make sure your API key is set properly."
            } else {
                message = apiError.localizedDescription
            }
        } else {
            message = "Please make sure you are connected to the internet and try again."
        }
        
        let alert = UIAlertController(title: "Error fetching configuration",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.updateConfiguration()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
