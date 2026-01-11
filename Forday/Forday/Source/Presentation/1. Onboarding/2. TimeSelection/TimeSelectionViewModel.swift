//
//  TimeSelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import Foundation
import Combine

class TimeSelectionViewModel {
    
    // Published Properties
    
    @Published var selectedTime: String?
    @Published var isNextButtonEnabled: Bool = false
    
    // Methods
    
    func selectTime(_ time: String) {
        selectedTime = time
        isNextButtonEnabled = true
    }
}
