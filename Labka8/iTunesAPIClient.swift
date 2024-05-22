//
//  iTunesAPIClient.swift
//  Labka8
//
//  Created by Admin on 01.12.2023.
//

import Foundation
struct SearchResponse: Codable {
    let results: [MediaItem]

    private enum CodingKeys: String, CodingKey {
        case results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decode([MediaItem].self, forKey: .results)
    }
}
class iTunesAPIClient {

    static let shared = iTunesAPIClient()
    private let baseURL = "https://itunes.apple.com/search"

    private init() {}

    func searchMedia(term: String, completion: @escaping (Result<[MediaItem], Error>) -> Void) {
        let url = URL(string: "\(baseURL)?term=\(term)&media=music")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(SearchResponse.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}



