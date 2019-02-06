//
//  BorderedButton.swift
//  DemoCalc
//
//  Created by Kamil on 04/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {

	convenience init(backgroundColor: UIColor = .white) {
		self.init(frame: .zero)
		self.backgroundColor = backgroundColor
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	private func initialize() {
		backgroundColor = .lightGray

		layer.borderColor = UIColor.gray.cgColor
		layer.borderWidth = 2
	}
}
