//
//  HobbyCard.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

import UIKit

struct HobbyCard: Codable {
    let id: Int?
    let name: String
    let description: String
    let imageAsset: HobbyImageAsset
}

enum HobbyImageAsset: String, Codable {
    case drawing = "drawing.png"
    case gym = "gym.png"
    case reading = "reading.png"
    case music = "music.png"
    case running = "running.png"
    case cooking = "cooking.png"
    case cafe = "cafe.png"
    case movie = "movie.png"
    case photo = "photo.png"
    case writing = "writing.png"
    
//    var image: UIImage? {
//        let assetName = self.rawValue.replacingOccurrences(of: ".png", with: "")
//        return UIImage(named: assetName)
//    }
    
    var image: UIImage {
        switch self {
        case .drawing:
                .Hobbycard.drawing
        case .gym:
                .Hobbycard.gym
        case .reading:
                .Hobbycard.reading
        case .music:
                .Hobbycard.listeningmusic
        case .running:
                .Hobbycard.running
        case .cooking:
                .Hobbycard.cooking
        case .cafe:
                .Hobbycard.cafe
        case .movie:
                .Hobbycard.watchingmovie
        case .photo:
                .Hobbycard.pictures
        case .writing:
                .Hobbycard.writing
        }
    }
}
