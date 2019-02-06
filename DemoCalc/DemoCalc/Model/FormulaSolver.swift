//
//  FormulaSolver.swift
//  DemoCalc
//
//  Created by Kamil on 04/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import Foundation
import BigNumber
import Repeat

protocol FormulaSolving {
	var delegate: FormulaSolverDelegate? { get set }
	func addNumber(value: BDouble)
	func addAction(value: Action)
	func clear()
}

private struct FormulaElement: CustomStringConvertible {
	var action: Action?
	var value: BDouble?

	var description: String {
		return action != nil ? action!.rawValue : value!.dcDecimalExpansion()
	}
}

protocol FormulaSolverDelegate: class {
	func onSolved(value: BDouble?)
}

class FormulaSolver: FormulaSolving {
	weak var delegate: FormulaSolverDelegate?
	private var formula = [FormulaElement]()
	private var lastAddedNumber = false
	private var throttler: Throttler!

	init(throttlerIntervalMiliseconds: Int = 150) {
		throttler = Throttler(time: Repeater.Interval.milliseconds(throttlerIntervalMiliseconds), { [weak self] in
			self?.solve()
		})
	}

	func addNumber(value: BDouble) {
		if lastAddedNumber {
			formula.removeLast()
		}
		formula.append(FormulaElement(action: nil, value: value))
		lastAddedNumber = true
		throttler.call()
	}

	func addAction(value: Action) {
		lastAddedNumber = false
		formula.append(FormulaElement(action: value, value: nil))
		throttler.call()
	}

	func clear() {
		lastAddedNumber = false
		formula.removeAll()
	}

	private func solve() {
		let rpnFormula = convertToRPN(formula: formula)
		print("\(rpnFormula)")
		let result = calculate(rpnFormula: rpnFormula)
		delegate?.onSolved(value: result)
	}

	private func convertToRPN(formula: [FormulaElement]) -> [FormulaElement] {
		var result = [FormulaElement]()
		var stack = [FormulaElement]()

		for element in formula {
			guard let action = element.action else {
				result.append(element)
				continue
			}
			if action == .leftParenthesis {
				stack.append(element)
				continue
			}
			if action == .rightParenthesis {
				while !stack.isEmpty {
					let lastElement = stack.removeLast()
					if lastElement.action! == .leftParenthesis {
						break
					}
					result.append(lastElement)
				}
				continue
			}
			while let topStackPrecedence = stack.last?.action?.precedence(), action.precedence() <= topStackPrecedence {
				result.append(stack.removeLast())
			}
			stack.append(element)
		}
		while !stack.isEmpty {
			let lastElement = stack.removeLast()
			result.append(lastElement)
		}
		return result
	}

	private func calculate(rpnFormula: [FormulaElement]) -> BDouble? {
		var stack = [BDouble]()
		for element in rpnFormula {
			guard let action = element.action else {
				stack.append(element.value!)
				continue
			}
			if stack.count < 2 {
				return nil
			}
			let valueR = stack.removeLast()
			let valueL = stack.removeLast()
			let result = action.calculate(valueL: valueL, valueR: valueR)
			guard let sureResult = result else {
				return nil
			}
			stack.append(sureResult)
		}
		return stack.last
	}
}
