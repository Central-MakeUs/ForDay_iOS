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
    
    // Coordinator에게 데이터 전달
    var onTimeSelected: ((Int) -> Void)?
    
    // Methods
    
    func selectTime(_ time: String) {
        selectedTime = time
        isNextButtonEnabled = true
        
        // String → Int 변환 후 클로저 호출
        let minutes = convertToMinutes(time)
        onTimeSelected?(minutes)
    }
    
    private func convertToMinutes(_ time: String) -> Int {
        switch time {
        case "10분": return 10
        case "20분": return 20
        case "30분": return 30
        case "1시간": return 60
        case "2시간": return 120
        default: return 0
        }
    }

    /// 초기 시간 설정 (온보딩 재개 시)
    func setInitialTime(_ minutes: Int) {
        let timeString = convertMinutesToString(minutes)
        selectedTime = timeString
        isNextButtonEnabled = true
        print("✅ 초기 시간 설정: \(minutes)분 (\(timeString))")
    }

    private func convertMinutesToString(_ minutes: Int) -> String {
        switch minutes {
        case 10: return "10분"
        case 20: return "20분"
        case 30: return "30분"
        case 60: return "1시간"
        case 120: return "2시간"
        default: return "\(minutes)분"
        }
    }
}
