//
//  DiagramController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: DiagramController
class DiagramController {
    
	// MARK: Stored Instance Properties
	var analysisRange = AnalysisRange.week {
		didSet {
			updateBounds()
		}
	}
	var selectedDate = Date() {
		didSet {
			updateBounds()
		}
	}
	var lowerDate: Date? = Date()
	var higherDate: Date? = Date()
	
	let formatterWeek: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d. MMM"
		formatter.locale = Calendar.current.locale
		return formatter
	}()
	let formatterMonth: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM YYYY"
		formatter.locale = Calendar.current.locale
		return formatter
	}()
	let formatterWeekWithYear: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d. MMM ’YY"
		formatter.locale = Calendar.current.locale
		formatter.locale = Calendar.current.locale
		return formatter
	}()
	
	// MARK: Initializers
	init() {
		updateBounds()
	}
	
    // MARK: Instance Methods
	func navigateBack() {
		switch analysisRange {
		case .week:
			selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
		case .month:
			selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
		case .year:
			selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
		}
	}
	
	func navigateForward() {
		switch analysisRange {
		case .week:
			selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
		case .month:
			selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
		case .year:
			selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
		}
	}
	
	func getRangeText() -> String {
		switch analysisRange {
		case .year:
			let dateComponents = Calendar.current.dateComponents([.year], from: selectedDate)
			return "\(dateComponents.year!)"
		case .week:
			//check if both have the same year
			if let lower = lowerDate,
				let higher = higherDate {
				let yearFirst = Calendar.current.dateComponents([.year], from: lower).year
				let yearSecond = Calendar.current.dateComponents([.year], from: higher).year
				if yearFirst == yearSecond {
					let monthFirst = Calendar.current.dateComponents([.month], from: lower).month
					let monthSecond = Calendar.current.dateComponents([.month], from: higher).month
					if monthFirst == monthSecond,
						let dayFirst = Calendar.current.dateComponents([.day], from: lower).day {
						return "\(dayFirst). - \(formatterWeekWithYear.string(from: higher))"
					} else {
						return "\(formatterWeek.string(from: lower)) - \(formatterWeekWithYear.string(from: higher))"
					}
				} else {
					return "\(formatterWeekWithYear.string(from: lower)) - \(formatterWeekWithYear.string(from: higher))"
				}
			}
		case .month:fallthrough
		default:
			return "\(formatterMonth.string(from: selectedDate))"
		}
		return ""
	}
    
    // MARK: Private Instance Methods
    private func updateBounds(){
        let calendar = Calendar.current
        switch analysisRange {
        case .week:
            lowerDate = selectedDate.previous(.monday)
            higherDate = selectedDate.next(.monday)
        case .month:
            let firstComponents = calendar.dateComponents([.year, .month], from: selectedDate)
            lowerDate = calendar.date(from: firstComponents)
            var nextComponents = DateComponents()
            nextComponents.month = 1
            higherDate = calendar.date(byAdding: nextComponents, to: selectedDate)
        case .year:
            let dateComponents = calendar.dateComponents([.year], from: selectedDate)
            lowerDate = calendar.date(from: dateComponents)
            if let lowerDate = lowerDate {
                higherDate = calendar.date(byAdding: .year, value: 1, to: lowerDate)
            }
        }
    }
	
}
