//
//  MovieDetailViewController.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/12/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit
import Kingfisher

class MovieDetailViewController : UIViewController {
    
    private let movie: Movie
    private lazy var movieDetailModel: MovieDetailModel = {
        MovieDetailModel(movie: movie, configuration: MovieDBConfiguration.current!)
    }()
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIBarButtonItem!

    init?(coder: NSCoder, movie: Movie) {
        self.movie = movie
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var sessionManager: SessionManager {
        Current.sessionManager
    }

    private var accountManager: AccountManager {
        Current.accountManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movieDetailModel.title
        yearLabel.text = movieDetailModel.year
        posterImageView.kf.setImage(with: movieDetailModel.posterURL)

        if sessionManager.isLoggedIn {
            let isFavorite = accountManager.isFavorite(movie: movie)
            toggleFavoriteButtonStatus(highlighted: isFavorite)
        } else {
            favoriteButton.isEnabled = false
        }
    }

    private func toggleFavoriteButtonStatus(highlighted: Bool) {
        let image = UIImage(systemName: highlighted ? "star.fill" : "star")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(favoriteTapped(_:)))
        favoriteButton = button
        navigationItem.rightBarButtonItem = favoriteButton
    }

    @IBAction func favoriteTapped(_ sender: UIBarButtonItem) {
        if accountManager.isFavorite(movie: movie) {
            toggleFavoriteButtonStatus(highlighted: false)
            accountManager.removeFavorite(movie: movie)
        } else {
            toggleFavoriteButtonStatus(highlighted: true)
            accountManager.addFavorite(movie: movie)
        }
    }
}
