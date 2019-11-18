//
//  MovieCell.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/9/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCell : UITableViewCell {
    static var identifier = "MovieCell"
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    func configure(with model: MovieCellModel) {
        titleLabel.text = model.title
        yearLabel.text = model.year
        posterImageView.kf.setImage(with: model.posterURL, options: [.transition(.fade(0.3))])
    }
    
    override func prepareForReuse() {
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        yearLabel.text = nil
    }
}
