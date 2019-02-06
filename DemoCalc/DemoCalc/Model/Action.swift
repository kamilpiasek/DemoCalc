//
//  Action.swift
//  DemoCalc
//
//  Created by Kamil on 05/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import Foundation
import BigNumber

enum Action: String {
	case addition
	case substraction
	case division
	case multiplication
	case leftParenthesis
	case rightParenthesis

	func precedence() -> Int {
		switch self {
		case .addition:
			return 1
		case .substraction:
			return 2
		case .division:
			return 4
		case .multiplication:
			return 3
		default:
			return 0
		}
	}

	func calculate(valueL: BDouble, valueR: BDouble) -> BDouble? {
		switch self {
		case .addition:
			return valueL + valueR
		case .substraction:
			return valueL - valueR
		case .division:
			if valueR == 0 {
				return nil
			}
			return valueL / valueR
		case .multiplication:
			return valueL * valueR
		default:
			return 0
		}
	}
}
