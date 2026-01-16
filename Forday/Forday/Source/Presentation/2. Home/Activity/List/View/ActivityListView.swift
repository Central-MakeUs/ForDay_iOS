//
//  ActivityListView.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class ActivityListView: UIView {
    
    // Properties
    
    let tableView = UITableView()
    private let emptyLabel = UILabel()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension ActivityListView {
    private func style() {
        backgroundColor = .systemBackground
        
        tableView.do {
            $0.backgroundColor = .systemBackground
            $0.separatorStyle = .none
            $0.register(ActivityCardCell.self, forCellReuseIdentifier: ActivityCardCell.identifier)
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 100
        }
        
        emptyLabel.do {
            $0.text = "현재 진행하고 있는 활동들이에요."
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.isHidden = true
        }
    }
    
    private func layout() {
        addSubview(tableView)
        addSubview(emptyLabel)
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
}

// Public Methods

extension ActivityListView {
    func setEmptyState(_ isEmpty: Bool) {
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}