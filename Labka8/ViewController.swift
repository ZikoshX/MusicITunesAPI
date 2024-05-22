//
//  ViewController.swift
//  Labka8
//
//  Created by Admin on 01.12.2023.
//

import UIKit
import AVKit
struct SearchResult: Codable {
    let results: [MediaItem]
}

struct MediaItem: Codable, Equatable {
    let trackName: String
    let artistName: String
    let artworkUrl100: String
    let previewUrl: String?

    enum CodingKeys: String, CodingKey {
        case trackName = "trackName"
        case artistName = "artistName"
        case artworkUrl100 = "artworkUrl100"
        case previewUrl = "previewUrl"
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

       private var searchBar = UISearchBar()
       private let tableView = UITableView()

       private var mediaItems: [MediaItem] = []
       private let imageCache = NSCache<NSString, UIImage>()
       private var videoPlayer: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search Media"
        view.addSubview(searchBar)

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }



    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           guard let searchTerm = searchBar.text else { return }
           searchMedia(with: searchTerm)
           searchBar.resignFirstResponder()
       }


    private func searchMedia(with term: String) {
        let url = createSearchURL(for: term)

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SearchResult.self, from: data)
                    self.mediaItems = result.results
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }

    private func createSearchURL(for term: String) -> URL {
        let baseUrl = "https://itunes.apple.com/search"
        let mediaType = "music"
        let limit = 50

        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: mediaType),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        return components.url!
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let mediaItem = mediaItems[indexPath.row]

            guard let videoUrl = URL(string: mediaItem.previewUrl ?? "") else {
                print("Invalid or nil URL for video playback.")
                return
            }

            videoPlayer = AVPlayer(url: videoUrl)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = videoPlayer

            present(playerViewController, animated: true) {
            self.videoPlayer?.play()
            }
        }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let mediaItem = mediaItems[indexPath.row]

        cell.textLabel?.text = mediaItem.trackName
        loadImage(for: mediaItem, into: cell.imageView)

        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("///", searchText)
    }

    private func loadImage(for mediaItem: MediaItem, into imageView: UIImageView?) {
        guard let imageUrl = URL(string: mediaItem.artworkUrl100) else { return }

        if let cachedImage = imageCache.object(forKey: imageUrl.absoluteString as NSString) {
            imageView?.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: imageUrl.absoluteString as NSString)
                    DispatchQueue.main.async {
                        imageView?.image = image
                        self.tableView.reloadRows(at: [IndexPath(row: self.mediaItems.firstIndex(of: mediaItem) ?? 0, section: 0)], with: .none)
                    }
                }
            }.resume()
        }
    }
}


