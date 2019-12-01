//
//  AccountManager.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/19/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

class AccountManager {
    var currentAccount: Account? {
        didSet {
            if let account = currentAccount {
                updateFavorites(for: account)
            } else {
                favorites = nil
            }
        }
    }
    private var favorites: Set<Movie>?

    private func updateFavorites(for account: Account) {
        self.favorites = []
        fetchFavorites(account: account)
    }

    func addFavorite(movie: Movie) {
        guard let account = currentAccount else { return }
        favorites?.insert(movie)
        MovieDB.api.send(request: .markFavorite(accountID: account.id, mediaType: "movie", mediaID: movie.id, favorite: true, { (result) in
            print("Add favorite: \(result)")
        }))
    }

    func removeFavorite(movie: Movie) {
        guard let account = currentAccount else { return }
        favorites?.remove(movie)
        MovieDB.api.send(request: .markFavorite(accountID: account.id, mediaType: "movie", mediaID: movie.id, favorite: false, { (result) in
            print("Remove favorite: \(result)")
        }))
    }

    func isFavorite(movie: Movie) -> Bool {
        guard let favorites = favorites else { return false }
        return favorites.contains(movie)
    }

    func fetchAccount(completion: @escaping (Result<Account, APIError>) -> Void) {
        print("Fetching account...")
        MovieDB.api.send(request: .account({ result in
            self.currentAccount = try? result.get()
            completion(result)
        }))
    }

    private func fetchFavorites(account: Account, pageNumber: Int = 1) {
        print("Fetching favorites (page: \(pageNumber))")
        MovieDB.api.send(request: .favoriteMovies(accountID: account.id, { result in
            switch result {
            case .success(let page):
                page.results.forEach { self.favorites?.insert($0) }
                if page.totalPages > pageNumber {
                    self.fetchFavorites(account: account, pageNumber: pageNumber+1)
                }
            case .failure(let error):
                print("Error fetching favorites: ", error)
            }
        }))
    }
}
