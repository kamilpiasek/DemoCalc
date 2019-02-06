//
//  AppInitializer.swift
//  DemoCalc
//
//  Created by Kamil on 06/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import Foundation

class AppInitializer {
	static let shared = AppInitializer()

	private var rootFlowController: RootFlowController!

	private init() {}
	func initialize() {
		rootFlowController = RootFlowController()
	}
}
