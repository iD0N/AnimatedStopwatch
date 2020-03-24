//
//  AnimatedStopWatch.swift
//  AnimatedStopWatch
//
//  Created by Don on 2/2/20.
//  Copyright © 2020 Don. All rights reserved.
//

import UIKit

enum AnimatedStopWatchStyle: Int {
	case two
	case three
}
@IBDesignable
public class AnimatedStopWatch: UIView, UIGestureRecognizerDelegate {
	
	@IBOutlet var contentView: UIView!
	
	// MARK: - IBInspectable customization variables
	
	@IBInspectable public var isCounterFaceHidden: Bool {
		get {
			return clockFaceImageView.isHidden
		}
		set {
			clockFaceImageView.isHidden = newValue
		}
	}
	@IBInspectable public var watchStyle: Int {
		get {
			return style.rawValue
		}
		set {
			style = AnimatedStopWatchStyle(rawValue: newValue)!
			labels.forEach {$0.removeFromSuperview()}
			backImages.forEach {$0.removeFromSuperview()}
			sepratorLabels.forEach {$0.removeFromSuperview()}
			labels = []
			backImages = []
			sepratorLabels = []
			configureStyle()
		}
	}
	@IBOutlet var clockFaceImageView: UIImageView!
	
	///This variable changes the clock face to a custom one (uses default face while nil)
	@IBInspectable public var clockFaceImage: UIImage?
	public var font: UIFont = .systemFont(ofSize: 40, weight: .bold) {
		didSet {
			applyAttributes()
		}
	}
	@IBInspectable public var numberColors: UIColor = .black {
		didSet {
			applyAttributes()
		}
	}
	//MARK: - Customization variables
	
	public var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 30)
	public var endDate: Date = Date(timeIntervalSinceNow: 15 * 60) {
		didSet {
			updateLabels()
		}
	}
	var delegate: AnimatedStopwatchDelegate?
	
	//MARK: - Private variables
	
	var stackView = { () -> UIStackView in
		let stack = UIStackView()
		stack.alignment = .center
		stack.axis = .horizontal
		stack.distribution = .equalSpacing
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	var labels: [UILabel] = []
	var backImages: [UIImageView] = []
	var sepratorLabels: [UILabel] = []
	
	
	var style: AnimatedStopWatchStyle = .two
	weak var timer: Timer?
	
	func applyAttributes()
	{
		for label in labels
		{
			label.font = font
			label.textColor = numberColors
		}
	}
	func updateLabels() {
		
		let now = Date()
		guard endDate > now else {
			timer?.invalidate()
			delegate?.didFinishCountdown(stopwatch: self)
			for i in labels
			{
				i.text = "0"
			}
			return
		}
        let calender:Calendar = Calendar.current
        let components: DateComponents = calender.dateComponents([.hour, .minute, .second], from: now, to: endDate)
        setupLabels(components: components)
	}
	func setupLabels(components: DateComponents) {
		
		switch style {
		case .two:
			guard let minute = components.minute, let second = components.second, labels.count >= 4 else {
				return
			}
			labels[0].text = "\(minute / 10)"
			labels[1].text = "\(minute % 10)"
			labels[2].text = "\(second / 10)"
			labels[3].text = "\(second % 10)"
		case .three:
			guard let hour = components.hour, let minute = components.minute, let second = components.second, labels.count >= 6 else {
				return
			}
			labels[0].text = "\(hour / 10)"
			labels[1].text = "\(hour % 10)"
			labels[2].text = "\(minute / 10)"
			labels[3].text = "\(minute % 10)"
			labels[4].text = "\(second / 10)"
			labels[5].text = "\(second % 10)"
		}
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	deinit {
		timer?.invalidate()
	}

	private func startTimer() {
		timer?.invalidate()      // stop prior timer, if any
		
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			self?.updateLabels()
		}
	}
	
	
	
	
	private func commonInit()
	{
		guard let view = loadViewFromNib() else { return }
		view.frame = bounds
		view.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
		
		addSubview(view)
		self.clipsToBounds = true
		contentView = view
		view.layoutIfNeeded()
		view.addSubview(stackView)
		updateLabels()
		startTimer()
		applyAttributes()
		configureStyle()
	}
	func configureStyle() {
		switch style {
		case .two:


			if let image = clockFaceImage
			{
				clockFaceImageView.image = image
				self.invalidateIntrinsicContentSize()
			}
			else
			{
				let image = UIImage(named: "counterfacesmall", in: .current, compatibleWith: nil)
				self.clockFaceImageView.image = image
				self.invalidateIntrinsicContentSize()
			}
			for _ in 0...3
			{
				let label = UILabel()
				label.textAlignment = .center
				label.textColor = .black
				label.translatesAutoresizingMaskIntoConstraints = false
				self.labels.append(label)
				contentView.addSubview(label)
				let image = UIImage(named: "counterback", in: .current, compatibleWith: nil)
				let backImage = UIImageView(image: image)
				self.stackView.addArrangedSubview(backImage)
				self.backImages.append(backImage)
				
				NSLayoutConstraint(item: backImage, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1.0, constant: -10).isActive = true
				NSLayoutConstraint(item: backImage, attribute: .centerX, relatedBy: .equal, toItem: label, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: backImage, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0/8.0, constant: 0).isActive = true
				NSLayoutConstraint(item: backImage, attribute: .height, relatedBy: .equal, toItem: backImage, attribute: .width, multiplier: 40.0/23.0, constant: 0).isActive = true
			}
			let label = UILabel()
			label.textAlignment = .center
			label.textColor = .black
			label.text = ":"
			label.font = .systemFont(ofSize: 30, weight: .bold)
			label.sizeToFit()
			self.sepratorLabels.append(label)
			self.stackView.insertArrangedSubview(label, at: 2)
		case .three:
			if let image = clockFaceImage
			{
				clockFaceImageView.image = image
				self.invalidateIntrinsicContentSize()
			}
			else
			{
				let image = UIImage(named: "counterfacebig", in: .current, compatibleWith: nil)
				self.clockFaceImageView.image = image
				self.invalidateIntrinsicContentSize()
			}
			for _ in 0...5
			{
				let label = UILabel()
				label.textAlignment = .center
				label.textColor = .black
				label.translatesAutoresizingMaskIntoConstraints = false
				self.labels.append(label)
				contentView.addSubview(label)
				let image = UIImage(named: "counterback", in: .current, compatibleWith: nil)
				let backImage = UIImageView(image: image)
				self.stackView.addArrangedSubview(backImage)
				self.backImages.append(backImage)
				
				NSLayoutConstraint(item: backImage, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1.0, constant: -10).isActive = true
				NSLayoutConstraint(item: backImage, attribute: .centerX, relatedBy: .equal, toItem: label, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
				NSLayoutConstraint(item: backImage, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0/14.0, constant: 0).isActive = true
				NSLayoutConstraint(item: backImage, attribute: .height, relatedBy: .equal, toItem: backImage, attribute: .width, multiplier: 40.0/23.0, constant: 0).isActive = true
			}
			for i in 0...1
			{
				let label = UILabel()
				label.textAlignment = .center
				label.textColor = .black
				label.text = ":"
				label.font = .systemFont(ofSize: 30, weight: .bold)
				label.sizeToFit()
				label.translatesAutoresizingMaskIntoConstraints = true
				self.sepratorLabels.append(label)
				self.stackView.insertArrangedSubview(label, at: 4 - i*2)
			}
		}
	}
	func loadViewFromNib() -> UIView? {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "AnimatedStopWatch", bundle: bundle)
		return nib.instantiate(
			withOwner: self,
			options: nil).first as? UIView
	}
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		stackView.translatesAutoresizingMaskIntoConstraints = true
		self.stackView.frame = self.bounds.inset(by: insets)
		self.contentView.frame = self.bounds
		
		self.clockFaceImageView.layoutIfNeeded()
		
	}
	
	public override var intrinsicContentSize: CGSize {
		let size = clockFaceImageView.image?.size ?? .zero
		
		return CGSize(width: self.bounds.width, height: size.height * (self.bounds.width/size.width))
	}
	public override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
		return .required
	}
	public override class func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
	}
}

class BundleDummy { }

extension Bundle {
	static var current = Bundle(for: BundleDummy.self)
}
