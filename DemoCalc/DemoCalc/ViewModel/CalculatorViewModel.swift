//
//  CalculatorViewModel.swift
//  DemoCalc
//
//  Created by Kamil on 04/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import Foundation
import BigNumber

protocol CalculatorViewModelDelegate: class {
	func onNewFormula(value: String)
	func onNewResult(value: BDouble?)
	func clear()
}

class CalculatorViewModel {
	weak var delegate: CalculatorViewModelDelegate?

	private var currentFormula = ""
	private var currentNumber = ""
	private var openParenthesisCount = 0
	private var lastAction: ActionViewModel?

	var formulaSolver: FormulaSolving?

	convenience init(formulaSolver: FormulaSolving) {
		self.init()
		self.formulaSolver = formulaSolver
		self.formulaSolver?.delegate = self
	}

	func addAction(action: ActionViewModel) {
		if !isCorrectAction(action: action) { return }
		if currentNumber.last == "." {
			currentFormula.removeLast()
		}
		if action == .leftParenthesis {
			openParenthesisCount += 1
		} else if action == .rightParenthesis {
			openParenthesisCount -= 1
		}
		lastAction = action
		currentFormula += ((action == .rightParenthesis || (action == .leftParenthesis && currentNumber.isEmpty)) ? "" : " ")
			+ action.asString()
			+ (action == .leftParenthesis ? "" : " ")
		formulaSolver?.addAction(value: action.asAction())
		currentNumber = ""
		delegate?.onNewFormula(value: currentFormula)
	}
	
	func addNumber(number: Int) {
		if currentNumber == "0" {
			currentNumber = ""
			currentFormula.removeLast()
		}
		currentNumber = currentNumber + "\(number)"
		currentFormula += "\(number)"
		if let number = BDouble(currentNumber) {
			formulaSolver?.addNumber(value: number)
		}
		delegate?.onNewFormula(value: currentFormula)
	}

	func addComma() {
		currentFormula += currentNumber.isEmpty ? "0." : "."
		currentNumber += currentNumber.isEmpty ? "0." : "."
		if let number = BDouble(currentNumber) {
			formulaSolver?.addNumber(value: number)
		}
		delegate?.onNewFormula(value: currentFormula)
	}

	func clearFormula() {
		currentNumber = ""
		currentFormula = ""
		formulaSolver?.clear()
		delegate?.clear()
	}

	private func isCorrectAction(action: ActionViewModel) -> Bool {
		return (action == .leftParenthesis && currentNumber.isEmpty)
			|| (action != .leftParenthesis && action != .rightParenthesis && (!currentNumber.isEmpty || lastAction == .rightParenthesis))
			|| (action == .rightParenthesis && openParenthesisCount > 0)
	}
}

extension CalculatorViewModel: FormulaSolverDelegate {
	func onSolved(value: BDouble?) {
		delegate?.onNewResult(value: value)
	}
}
