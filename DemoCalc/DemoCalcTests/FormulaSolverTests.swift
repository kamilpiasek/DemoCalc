//
//  FormulaSolverTests.swift
//  DemoCalcTests
//
//  Created by Kamil on 06/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import XCTest
import Nimble
import Quick
import BigNumber

@testable import DemoCalc

class MockFormulaSolverDelegate: FormulaSolverDelegate {
	var onSolvedCallCount = 0
	var solvedLastValue: BDouble?
	var solvedValueWasNilCount = 0

	func onSolved(value: BDouble?) {
		onSolvedCallCount += 1
		solvedLastValue = value
		solvedValueWasNilCount += value == nil ? 1 : 0
	}
}

class FormulaSolverTests: QuickSpec {

	override func spec() {
		describe("FormulaSolver`") {

			var mockFormulaSolverDelegate: MockFormulaSolverDelegate?
			var sut: FormulaSolver!

			beforeEach {
				mockFormulaSolverDelegate = MockFormulaSolverDelegate()
				sut = FormulaSolver(throttlerIntervalMiliseconds: 1)
				sut.delegate = mockFormulaSolverDelegate
			}

			context("should calculate proper results for proper formulas", closure: {
				it("should return number when provided with single number", closure: {
					sut.addNumber(value: 5)
					expect(mockFormulaSolverDelegate?.onSolvedCallCount).toEventually(equal(1))
					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(5))
				})

				it("should return number when provided with simple formula", closure: {
					sut.addNumber(value: 5)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 13)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(18))
				})

				it("5 + 2 * 3 == 11", closure: {
					sut.addNumber(value: 5)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 2)
					sut.addAction(value: Action.multiplication)
					sut.addNumber(value: 3)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(11))
				})

				it("(5 + 2) * 3 == 21", closure: {
					sut.addAction(value: Action.leftParenthesis)
					sut.addNumber(value: 5)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 2)
					sut.addAction(value: Action.rightParenthesis)
					sut.addAction(value: Action.multiplication)
					sut.addNumber(value: 3)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(21))
				})

				it("(5 + 2) * 3 == 21", closure: {
					sut.addAction(value: Action.leftParenthesis)
					sut.addNumber(value: 5)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 2)
					sut.addAction(value: Action.rightParenthesis)
					sut.addAction(value: Action.multiplication)
					sut.addNumber(value: 3)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(21))
				})

				it("(5 + 2) * (5 - 2) == 21", closure: {
					sut.addAction(value: Action.leftParenthesis)
					sut.addNumber(value: 5)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 2)
					sut.addAction(value: Action.rightParenthesis)
					sut.addAction(value: Action.multiplication)
					sut.addAction(value: Action.leftParenthesis)
					sut.addNumber(value: 5)
					sut.addAction(value: Action.substraction)
					sut.addNumber(value: 2)
					sut.addAction(value: Action.rightParenthesis)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(21))
				})

				it("(5 + 0) / (5 - 3) == 2.5", closure: {
					sut.addAction(value: Action.leftParenthesis)
					sut.addNumber(value: 5)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 0)
					sut.addAction(value: Action.rightParenthesis)
					sut.addAction(value: Action.division)
					sut.addAction(value: Action.leftParenthesis)
					sut.addNumber(value: 5)
					sut.addAction(value: Action.substraction)
					sut.addNumber(value: 3)
					sut.addAction(value: Action.rightParenthesis)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(2.5))
				})

				it("5.1 + 1.1 == 6.2", closure: {
					sut.addNumber(value: 5.1)
					sut.addAction(value: Action.addition)
					sut.addNumber(value: 1.1)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(6.2))
				})

				it("0.42 * 100 == 42", closure: {
					sut.addNumber(value: 0.042)
					sut.addAction(value: Action.multiplication)
					sut.addNumber(value: 1000)

					expect(mockFormulaSolverDelegate?.solvedLastValue).toEventually(equal(42))
				})
			})

			context("should return errors for incorrect formulas", closure: {

				it("should return error when provided with single action", closure: {
					sut.addAction(value: .addition)
					expect(mockFormulaSolverDelegate?.onSolvedCallCount).toEventually(equal(1))
					expect(mockFormulaSolverDelegate?.solvedValueWasNilCount).toEventually(equal(1))
				})

				it("should return error when incorrect number of parenthesis", closure: {
					sut.addAction(value: .leftParenthesis)
					DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
						sut.addNumber(value: 10)
						DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
							sut.addAction(value: .addition)
							DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
								sut.addNumber(value: 5)
							})
						})
					})
					expect(mockFormulaSolverDelegate?.onSolvedCallCount).toEventually(equal(4), timeout: 3)
					expect(mockFormulaSolverDelegate?.solvedValueWasNilCount).toEventually(equal(4), timeout: 3)
				})

				it("should return error when operator at the end of formula", closure: {
					sut.addNumber(value: 10)
					DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
						sut.addAction(value: .addition)
					})
					expect(mockFormulaSolverDelegate?.onSolvedCallCount).toEventually(equal(2), timeout: 2)
					expect(mockFormulaSolverDelegate?.solvedValueWasNilCount).toEventually(equal(1), timeout: 2)
				})

			})
		}
	}

}
