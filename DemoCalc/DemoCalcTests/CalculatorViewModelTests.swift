//
//  CalculatorViewModelTests.swift
//  CalculatorViewModelTests
//
//  Created by Kamil on 04/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import XCTest
import Nimble
import Quick
import BigNumber

@testable import DemoCalc

class MockFormulaSolver: FormulaSolving {
	var addNumberCallCount = 0
	var addActionCallCount = 0
	var clearCallCount = 0

	var delegate: FormulaSolverDelegate?

	func addNumber(value: BDouble) {
		addNumberCallCount += 1
	}

	func addAction(value: Action) {
		addActionCallCount += 1
	}

	func clear() {
		clearCallCount += 1
	}
}

class MockCalculatorViewModelDelegate: CalculatorViewModelDelegate {
	var onNewFormulaCallCount = 0
	var newFormulaLastValue: String?
	var newFormulaLastValueWasNil: Bool = false
	var onNewResultCallCount = 0
	var newResultLastValue: BDouble?
	var clearCallCount = 0

	func onNewFormula(value: String) {
		onNewFormulaCallCount += 1
		newFormulaLastValue = value
	}

	func onNewResult(value: BDouble?) {
		onNewResultCallCount += 1
		newResultLastValue = value
	}

	func clear() {
		clearCallCount += 1
	}
}

class CalculatorViewModelTests: QuickSpec {

	override func spec() {
		describe("CalculatorViewModel`") {
			context("after beeing initialized", closure: {
				var mockFormulaSolver: MockFormulaSolver!
				var mockCalculatorViewModelDelegate: MockCalculatorViewModelDelegate!
				var sut: CalculatorViewModel!

				beforeEach {
					mockFormulaSolver = MockFormulaSolver()
					mockCalculatorViewModelDelegate = MockCalculatorViewModelDelegate()
					sut = CalculatorViewModel(formulaSolver: mockFormulaSolver)
					sut.delegate = mockCalculatorViewModelDelegate
				}

				it("should allow to add number to empty formula and produce proper formula output", closure: {
					sut.addNumber(number: 1)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("1"))
				})

				it("should allow to add new action to formula after adding number and produce proper formula output", closure: {
					sut.addNumber(number: 1)
					sut.addAction(action: ActionViewModel.addition)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockFormulaSolver.addActionCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(2))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("1 + "))
				})

				it("should not allow to add action to formula without adding number first and not produce formula output", closure: {
					sut.addAction(action: ActionViewModel.addition)

					expect(mockFormulaSolver.addActionCallCount).to(equal(0))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(0))
				})

				it("should not allow to add action(+-*/) multiple times after adding other action(+-*/) first and produce proper formula output", closure: {
					sut.addNumber(number: 1)
					sut.addAction(action: ActionViewModel.addition)
					sut.addAction(action: ActionViewModel.addition)
					sut.addAction(action: ActionViewModel.multiplication)
					sut.addAction(action: ActionViewModel.division)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockFormulaSolver.addActionCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(2))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("1 + "))
				})

				it("should allow to add left parenthesis to formula without adding number and produce proper formula output", closure: {
					sut.addAction(action: ActionViewModel.leftParenthesis)

					expect(mockFormulaSolver.addActionCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("("))
				})

				it("should not allow to add left parenthesis to formula after adding number and produce proper formula output", closure: {
					sut.addNumber(number: 1)
					sut.addAction(action: ActionViewModel.leftParenthesis)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockFormulaSolver.addActionCallCount).to(equal(0))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("1"))
				})

				it("should allow to add left parenthesis to formula after adding other action (+-*/) and produce proper formula output", closure: {
					sut.addNumber(number: 1)
					sut.addAction(action: ActionViewModel.division)
					sut.addAction(action: ActionViewModel.leftParenthesis)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockFormulaSolver.addActionCallCount).to(equal(2))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(3))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("1 / ("))
				})

				it("should not allow to add right parenthesis without adding left parenthesis first", closure: {
					sut.addAction(action: ActionViewModel.rightParenthesis)

					expect(mockFormulaSolver.addActionCallCount).to(equal(0))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(0))
				})

				it("should allow to input correct number and produce proper formula output", closure: {
					sut.addNumber(number: 4)
					sut.addComma()
					sut.addNumber(number: 2)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(3))
					expect(mockFormulaSolver.addActionCallCount).to(equal(0))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(3))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("4.2"))
				})

				it("should convert single . to 0. in produced output", closure: {
					sut.addComma()

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("0."))
				})

				it("should convert 1. to 1 in produced output when adding action after comma", closure: {
					sut.addNumber(number: 5)
					sut.addComma()
					sut.addAction(action: ActionViewModel.addition)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(2))
					expect(mockFormulaSolver.addActionCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(3))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("5 + "))
				})

				it("should correctly clear formula", closure: {
					sut.addNumber(number: 5)
					sut.addAction(action: ActionViewModel.addition)
					sut.clearFormula()

					expect(mockFormulaSolver.addNumberCallCount).to(equal(1))
					expect(mockFormulaSolver.addActionCallCount).to(equal(1))
					expect(mockFormulaSolver.clearCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.clearCallCount).to(equal(1))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(2))
				})

				it("should allow to input correct formula and produce proper formula output", closure: {
					sut.addNumber(number: 4)
					sut.addComma()
					sut.addNumber(number: 2)
					sut.addAction(action: ActionViewModel.division)
					sut.addAction(action: ActionViewModel.leftParenthesis)
					sut.addNumber(number: 6)
					sut.addAction(action: ActionViewModel.substraction)
					sut.addNumber(number: 5)
					sut.addAction(action: ActionViewModel.rightParenthesis)

					expect(mockFormulaSolver.addNumberCallCount).to(equal(5))
					expect(mockFormulaSolver.addActionCallCount).to(equal(4))
					expect(mockCalculatorViewModelDelegate.onNewFormulaCallCount).to(equal(9))
					expect(mockCalculatorViewModelDelegate.newFormulaLastValue).to(equal("4.2 / (6 - 5) "))
				})
			})
		}
	}

}
