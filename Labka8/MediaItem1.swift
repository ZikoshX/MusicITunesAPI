//
//  MediaItem.swift
//  Labka8
//
//  Created by Admin on 01.12.2023.
//

import Foundation
struct MediaItem1: Codable {
    let trackName: String
    let artistName: String

    private enum CodingKeys: String, CodingKey {
        case trackName
        case artistName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trackName = try container.decode(String.self, forKey: .trackName)
        artistName = try container.decode(String.self, forKey: .artistName)
    }
}


