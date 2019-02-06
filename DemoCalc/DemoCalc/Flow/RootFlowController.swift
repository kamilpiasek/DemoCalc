//
//  RootFlowController.swift
//  DemoCalc
//
//  Created by Kamil on 06/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import UIKit

class RootFlowController {
	init() {
		setupRootViewController()
	}

	private func setupRootViewController() {
		let appDelegate = UIApplication.shared.delegate as? AppDelegate
		let formulaSolver = FormulaSolver()
		let caculatorViewModel = CalculatorViewModel(formulaSolver: formulaSolver)
		let calculatorViewController = CalculatorViewController(viewModel: caculatorViewModel)
		appDelegate?.window?.rootViewController = calculatorViewController
	}
}
