//
//  AIRecommendationLoadingViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import SnapKit
import Then
import Lottie

class AIRecommendationLoadingViewController: UIViewController {

    // Properties

    private let hobbyId: Int
    private let loadingView = AIRecommendationLoadingView()

    // Initialization

    init(hobbyId: Int) {
        self.hobbyId = hobbyId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Lifecycle

    override func loadView() {
        view = loadingView
    }
}

#Preview {
    AIRecommendationLoadingViewController(hobbyId: 1)
}
