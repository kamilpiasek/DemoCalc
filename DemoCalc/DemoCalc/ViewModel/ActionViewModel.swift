//
//  ActionViewModel.swift
//  DemoCalc
//
//  Created by Kamil on 04/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import Foundation

enum ActionViewModel: Int {
	case addition
	case substraction
	case division
	case multiplication
	case leftParenthesis
	case rightParenthesis

	static func all() -> [ActionViewModel] {
		return [.addition, .substraction, .division, .multiplication, .leftParenthesis, .rightParenthesis]
	}

	func asString() -> String {
		switch self {
		case .addition: return "+"
		case .substraction: return "-"
		case .division: return "/"
		case .multiplication: return "*"
		case .leftParenthesis: return "("
		case .rightParenthesis: return ")"
		}
	}

	func asAction() -> Action {
		switch self {
		case .addition: return .addition
		case .substraction: return .substraction
		case .division: return .division
		case .multiplication: return .multiplication
		case .leftParenthesis: return .leftParenthesis
		case .rightParenthesis: return .rightParenthesis
		}
	}
}
