//
//  PopularMoviesViewController.swift
//  MovieLister
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit
import SimpleNetworking

class PopularMoviesViewController : UITableViewController {
    
    enum Section {
        case main
    }
    
    private var movies: [Movie] = []
    private var datasource: UITableViewDiffableDataSource<Section, MovieCellModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, movieCellModel) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
            cell.configure(with: movieCellModel)
            return cell
        })
     
        fetchMovies()
    }
    
    private func fetchMovies() {
        guard let config = MovieDBConfiguration.current else { return }
        MovieDB.api.send(request: MovieDB.popularMovies()) {
            (result: Result<PagedResults<Movie>, APIError>) in
            
            switch result {
            case .success(let page):
                self.movies = page.results
                var snapshot = NSDiffableDataSourceSnapshot<Section, MovieCellModel>()
                snapshot.appendSections([.main])
                let models = page.results.map { MovieCellModel(movie: $0, configuration: config) }
                snapshot.appendItems(models, toSection: .main)
                self.datasource.apply(snapshot)
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @IBSegueAction
    private func showMovie(coder: NSCoder, sender: Any, segueIdentifier: String) -> MovieDetailViewController? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        let movie = movies[indexPath.row]
        let movieVC = MovieDetailViewController(coder: coder, movie: movie)
        return movieVC
    }
}
