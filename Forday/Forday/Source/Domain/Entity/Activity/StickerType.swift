//
//  StickerType.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import UIKit

/// Represents the type of sticker that can be used in activity records
enum StickerType: String, Codable, CaseIterable {
    case smile = "smile.jpg"
    case sad = "sad.jpg"
    case laugh = "laugh.jpg"
    case angry = "angry.jpg"

    /// Returns the corresponding UIImage asset for the sticker
    var image: UIImage {
        switch self {
        case .smile:
            return .My.smileJpg
        case .sad:
            return .My.sadJpg
        case .laugh:
            return .My.laughJpg
        case .angry:
            return .My.angryJpg
        }
    }

    /// Returns the gradient associated with this sticker type
    var gradient: AppGradient {
        switch self {
        case .smile:
            return DesignGradient.stickerSmile
        case .sad:
            return DesignGradient.stickerSad
        case .angry:
            return DesignGradient.stickerAngry
        case .laugh:
            return DesignGradient.stickerLaugh
        }
    }

    /// Returns the card template background image for this sticker type
    var cardTemplateBackground: UIImage {
        switch self {
        case .smile:
            return .Template.cardSmile
        case .sad:
            return .Template.cardSad
        case .laugh:
            return .Template.cardLaugh
        case .angry:
            return .Template.cardAngry
        }
    }

    /// Returns the gradient template overlay for this sticker type
    var templateGradient: AppGradient {
        switch self {
        case .smile:
            return DesignGradient.templateSmile
        case .sad:
            return DesignGradient.templateSad
        case .laugh:
            return DesignGradient.templateLaugh
        case .angry:
            return DesignGradient.templateAngry
        }
    }

    /// Initialize from a filename string
    /// - Parameter fileName: The sticker filename (e.g., "smile.jpg" or "smile")
    /// - Returns: The corresponding StickerType, or nil if not recognized
    init?(fileName: String) {
        // Try exact match first (with .jpg extension)
        if let type = StickerType(rawValue: fileName) {
            self = type
            return
        }

        // Try matching without extension
        let normalizedName = fileName.lowercased()
            .replacingOccurrences(of: ".jpg", with: "")
            .replacingOccurrences(of: ".png", with: "")

        switch normalizedName {
        case "smile":
            self = .smile
        case "sad":
            self = .sad
        case "laugh":
            self = .laugh
        case "angry":
            self = .angry
        default:
            return nil
        }
    }
}
