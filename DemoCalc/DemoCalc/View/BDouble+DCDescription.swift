//
//  BDouble+DCDescription.swift
//  DemoCalc
//
//  Created by Kamil on 06/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import Foundation
import BigNumber

extension BDouble {
	func dcDecimalExpansion() -> String {
		var value = decimalExpansion(precisionAfterDecimalPoint: 15, rounded: true)
		while value.last == "0" && !value.hasSuffix(".0") {
			value.removeLast()
		}
		return value
	}
}
