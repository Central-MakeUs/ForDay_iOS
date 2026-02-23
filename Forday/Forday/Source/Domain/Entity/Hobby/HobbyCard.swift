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

/// API imageCode와 1:1 매핑되는 enum
enum HobbyImageAsset: String, Codable {
    case drawing = "DRAWING_ICON"
    case gym = "GYM_ICON"
    case reading = "READING_ICON"
    case music = "MUSIC_ICON"
    case running = "RUNNING_ICON"
    case cooking = "COOKING_ICON"
    case cafe = "CAFE_ICON"
    case movie = "MOVIE_ICON"
    case photo = "PHOTO_ICON"
    case writing = "WRITING_ICON"
    case `default` = "DEFAULT_ICON"

    /// API imageCode로 초기화 (rawValue 사용)
    /// e.g., "DRAWING_ICON" -> .drawing
    init?(imageCode: String) {
        if let asset = HobbyImageAsset(rawValue: imageCode) {
            self = asset
        } else {
            self = .default
        }
    }

    /// API metadata imageCode 형식으로 초기화
    /// e.g., "drawing.png" -> .drawing
    init?(fromApiImageCode code: String) {
        // ".png" 확장자 제거 후 매핑
        let name = code.replacingOccurrences(of: ".png", with: "")
        let mapping: [String: HobbyImageAsset] = [
            "drawing": .drawing,
            "gym": .gym,
            "reading": .reading,
            "music": .music,
            "running": .running,
            "cooking": .cooking,
            "cafe": .cafe,
            "movie": .movie,
            "photo": .photo,
            "writing": .writing
        ]

        if let asset = mapping[name] {
            self = asset
        } else {
            return nil
        }
    }

    /// 한글 취미명으로 초기화
    init?(hobbyName: String) {
        let mapping: [String: HobbyImageAsset] = [
            "그림 그리기": .drawing,
            "그림그리기": .drawing,
            "헬스": .gym,
            "운동": .gym,
            "독서": .reading,
            "음악 듣기": .music,
            "음악듣기": .music,
            "러닝": .running,
            "요리": .cooking,
            "카페 탐방": .cafe,
            "카페탐방": .cafe,
            "영화 보기": .movie,
            "영화보기": .movie,
            "사진 촬영": .photo,
            "사진촬영": .photo,
            "글쓰기": .writing
        ]

        if let asset = mapping[hobbyName] {
            self = asset
        } else {
            return nil
        }
    }
    
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
        case .default:
                .Hobbycard.cafe
        }
    }
    
    var icon: UIImage {
        switch self {
        case .drawing:
                .Hobbyicon.drawing
        case .gym:
                .Hobbyicon.gym
        case .reading:
                .Hobbyicon.reading
        case .music:
                .Hobbyicon.listeningmusic
        case .running:
                .Hobbyicon.running
        case .cooking:
                .Hobbyicon.cooking
        case .cafe:
                .Hobbyicon.cafe
        case .movie:
                .Hobbyicon.watchingmovie
        case .photo:
                .Hobbyicon.pictures
        case .writing:
                .Hobbyicon.writing
        case .default:
                .Hobbyicon.default
        }
    }

    var hobbySelectionIcon: UIImage {
        switch self {
        case .drawing:
                .HobbySelectionIcon.drawing
        case .gym:
                .HobbySelectionIcon.gym
        case .reading:
                .HobbySelectionIcon.reading
        case .music:
                .HobbySelectionIcon.listeningmusic
        case .running:
                .HobbySelectionIcon.running
        case .cooking:
                .HobbySelectionIcon.cooking
        case .cafe:
                .HobbySelectionIcon.cafe
        case .movie:
                .HobbySelectionIcon.watchingmovie
        case .photo:
                .HobbySelectionIcon.pictures
        case .writing:
                .HobbySelectionIcon.writing
        case .default:
                .HobbySelectionIcon.cafe
        }
    }
}
