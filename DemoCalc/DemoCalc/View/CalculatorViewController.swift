//
//  CalculatorViewController.swift
//  DemoCalc
//
//  Created by Kamil on 04/02/2019.
//  Copyright © 2019 KP. All rights reserved.
//

import UIKit
import SnapKit
import BigNumber

class CalculatorViewController: UIViewController {
	private var viewModel: CalculatorViewModel?

	private let formulaContainer = UIView()
	private let formulaTitleLabel = UILabel()
	private let formulaLabel = UILabel()

	private let resultContainer = UIView()
	private let resultTitleLabel = UILabel()
	private let resultLabel = UILabel()

	private let keypadStackView = UIStackView()
	private var numberButtons = [UIButton]()
	private var actionButtons = [UIButton]()
	private let commaButton = BorderedButton(backgroundColor: .orange)
	private let clearButton = BorderedButton(backgroundColor: .orange)

	convenience init(viewModel: CalculatorViewModel) {
		self.init(nibName: nil, bundle: nil)
		self.viewModel = viewModel
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel?.delegate = self
		setupViews()
	}

	private func setupViews() {
		view.backgroundColor = .gray

		formulaContainer.backgroundColor = .white
		view.addSubview(formulaContainer)

		formulaTitleLabel.text = "Formula:"
		formulaTitleLabel.font = UIFont.systemFont(ofSize: 12)
		formulaContainer.addSubview(formulaTitleLabel)

		formulaLabel.textAlignment = .left
		formulaLabel.adjustsFontSizeToFitWidth = true
		formulaLabel.minimumScaleFactor = 0.2
		formulaLabel.numberOfLines = 2
		formulaContainer.addSubview(formulaLabel)

		resultContainer.backgroundColor = .white
		view.addSubview(resultContainer)

		resultTitleLabel.text = "Result:"
		resultTitleLabel.font = UIFont.systemFont(ofSize: 12)
		resultContainer.addSubview(resultTitleLabel)

		resultLabel.textAlignment = .left
		resultLabel.adjustsFontSizeToFitWidth = true
		resultLabel.minimumScaleFactor = 0.2
		resultLabel.numberOfLines = 2
		resultContainer.addSubview(resultLabel)

		keypadStackView.axis = .vertical
		keypadStackView.distribution = .fillEqually
		view.addSubview(keypadStackView)

		for number in 0...9 {
			let button = createNumberButton(with: number)
			numberButtons.append(button)
		}

		for action in ActionViewModel.all() {
			let button = createActionButton(with: action)
			actionButtons.append(button)
		}

		let firstLineStackView = createNumbersLineStackView(with: Array(numberButtons[7...9] + actionButtons[0...1]))
		keypadStackView.addArrangedSubview(firstLineStackView)

		let secondLineStackView = createNumbersLineStackView(with: Array(numberButtons[4...6] + actionButtons[2...3]))
		keypadStackView.addArrangedSubview(secondLineStackView)

		let thirdLineStackView = createNumbersLineStackView(with: Array(numberButtons[1...3] + actionButtons[4...5]))
		keypadStackView.addArrangedSubview(thirdLineStackView)

		let fourthLineContainer = UIView()
		keypadStackView.addArrangedSubview(fourthLineContainer)

		fourthLineContainer.addSubview(numberButtons[0])

		commaButton.setTitle(".", for: .normal)
		commaButton.addTarget(self, action: #selector(onCommaButtonTap), for: .touchUpInside)
		fourthLineContainer.addSubview(commaButton)

		clearButton.setTitle("AC", for: .normal)
		clearButton.addTarget(self, action: #selector(onClearButtonTap), for: .touchUpInside)
		fourthLineContainer.addSubview(clearButton)

		setupConstraints()
	}

	private func setupConstraints() {
		let standardMargin: CGFloat = 10
		formulaContainer.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(standardMargin)
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.height.equalTo(100)
		}

		formulaTitleLabel.snp.makeConstraints { make in
			make.left.top.equalToSuperview().inset(standardMargin)
		}

		formulaLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.right.equalToSuperview().inset(standardMargin)
		}

		resultContainer.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(standardMargin)
			make.top.equalTo(formulaContainer.snp.bottom).offset(standardMargin)
			make.height.equalTo(100)
		}

		resultTitleLabel.snp.makeConstraints { make in
			make.left.top.equalToSuperview().inset(standardMargin)
		}

		resultLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.right.equalToSuperview().inset(standardMargin)
		}

		keypadStackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(standardMargin)
			make.top.equalTo(resultContainer.snp.bottom).offset(30)
			make.height.equalTo(keypadStackView.snp.width).multipliedBy(4.0/5.0)
		}

		commaButton.snp.makeConstraints { make in
			make.bottom.top.equalToSuperview()
			make.width.equalTo(commaButton.snp.height)
			make.left.equalTo(numberButtons[0].snp.right)
		}

		clearButton.snp.makeConstraints { make in
			make.right.bottom.top.equalToSuperview()
			make.width.equalTo(commaButton.snp.height)
			make.left.equalTo(commaButton.snp.right)
		}

		numberButtons[0].snp.makeConstraints { make in
			make.left.bottom.top.equalToSuperview()
		}
	}

	private func createNumberButton(with number: Int) -> UIButton {
		let button = BorderedButton()
		button.setTitle("\(number)", for: .normal)
		button.tag = number
		button.addTarget(self, action: #selector(onNumberButtonTap(sender:)), for: .touchUpInside)
		return button
	}

	private func createNumbersLineStackView(with buttons: [UIButton]) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: buttons)
		stackView.distribution = .fillEqually
		stackView.axis = .horizontal
		return stackView
	}

	private func createActionButton(with actionViewModel: ActionViewModel) -> UIButton {
		let button = BorderedButton(backgroundColor: .orange)
		button.setTitle(actionViewModel.asString(), for: .normal)
		button.tag = actionViewModel.rawValue
		button.addTarget(self, action: #selector(onActionButtonTap(sender:)), for: .touchUpInside)
		return button
	}

	@objc private func onNumberButtonTap(sender: UIButton) {
		viewModel?.addNumber(number: sender.tag)
	}

	@objc private func onActionButtonTap(sender: UIButton) {
		guard let actionViewModel = ActionViewModel(rawValue: sender.tag) else { return }
		viewModel?.addAction(action: actionViewModel)
	}

	@objc private func onCommaButtonTap() {
		viewModel?.addComma()
	}

	@objc private func onClearButtonTap() {
		viewModel?.clearFormula()
	}
}

extension CalculatorViewController: CalculatorViewModelDelegate {
	func onNewFormula(value: String) {
		formulaLabel.text = value
	}

	func clear() {
		resultLabel.text = ""
		formulaLabel.text = ""
	}

	func onNewResult(value: BDouble?) {
		DispatchQueue.main.async { [weak self] in
			guard let value = value else {
				self?.resultLabel.text = "ERROR"
				return
			}
			self?.resultLabel.text = value.dcDecimalExpansion()
		}
	}
}

