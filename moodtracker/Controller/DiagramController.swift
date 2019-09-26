//
//  DiagramController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

class DiagramController {
	// MARK: Stored properties
	var analysisrange = AnalysisRange.week{
		didSet{
			updateBounds()
		}
	}
	var selectedDate = Date(){
		didSet{
			updateBounds()
		}
	}
	var lowerDate: Date? = Date()
	var higherDate: Date? = Date()
	
	let formatterWeek: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd MMM YY"
		formatter.locale = Calendar.current.locale
		return formatter
	}()
	let formatterMonth: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM YYYY"
		formatter.locale = Calendar.current.locale
		return formatter
	}()
	
	
	// MARK: Initializers
	init() {
		updateBounds()
	}
	
	// MARK: Instance Methods
	private func updateBounds(){
		let calendar = Calendar.current
		switch analysisrange {
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
	
	func navigateBack(){
		switch analysisrange {
		case .week:
			selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
		case .month:
			selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
		case .year:
			selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
		}
	}
	
	func navigateForward(){
		switch analysisrange {
		case .week:
			selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
		case .month:
			selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
		case .year:
			selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
		}
	}
	
	func getRangeText() -> String {
		switch analysisrange {
		case .year:
			let dateComponents = Calendar.current.dateComponents([.year], from: selectedDate)
			return "\(dateComponents.year!)"
		case .week:
			if let lower = lowerDate,
				let higher = higherDate {
				return "\(formatterWeek.string(from: lower)) - \(formatterWeek.string(from: higher))"
			}
		case .month:fallthrough
		default:
			return "\(formatterMonth.string(from: selectedDate))"
		}
		return ""
	}
	
}
