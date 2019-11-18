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
    
    init?(coder: NSCoder, movie: Movie) {
        self.movie = movie
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movieDetailModel.title
        yearLabel.text = movieDetailModel.year
        posterImageView.kf.setImage(with: movieDetailModel.posterURL)
    }
}
