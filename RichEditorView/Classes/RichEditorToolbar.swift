//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: class {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

/// RichBarButton is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
@objcMembers open class RichBarButton: UIButton {
    open var actionHandler: (() -> Void)?

    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        self.init(frame: CGRect.zero)
        setImage(image, for: .normal)
        addTarget(self, action: #selector(RichBarButton.buttonWasTapped), for: .touchUpInside)
        actionHandler = handler
    }

    @objc func buttonWasTapped() {
        actionHandler?()
    }
}

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return toolbarStackView.backgroundColor }
        set { toolbarStackView.backgroundColor = newValue }
    }

    // Views
    private let backingView = UIView()
    private let gradientView = GradientView()
    private var toolbarStackView = UIStackView()
    private var dividerLineView = UIView()
    public let dismissButton = UIButton(type: .custom)

    // Constants
    private let gradientHeight: CGFloat = 10
    private let dismissButtonSize: CGSize = CGSize(width: 25, height: 25)
    private let dismissButtonInset: CGFloat = 5
    private let toolbarHeight: CGFloat = 44


    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        autoresizingMask = .flexibleWidth

        backgroundColor = .clear

        backingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backingView.backgroundColor = .white
        addSubview(backingView)

        gradientView.autoresizingMask = [.flexibleWidth]
        gradientView.frame.size.height = gradientHeight
        gradientView.backgroundColor = .clear
        addSubview(gradientView)

        toolbarStackView.autoresizingMask = .flexibleWidth
        toolbarStackView.axis = .horizontal
        toolbarStackView.alignment = .fill
        toolbarStackView.distribution = .equalSpacing
        toolbarStackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        toolbarStackView.isLayoutMarginsRelativeArrangement = true

        dividerLineView.backgroundColor = UIColor(red: 145.0 / 255.0, green: 145.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)
        dividerLineView.frame.size.height = 0.5
        dividerLineView.frame.origin = frame.origin
        dividerLineView.autoresizingMask = [.flexibleWidth]
        toolbarStackView.addSubview(dividerLineView)

        let dismissImage = UIImage(named: "down", in: Bundle(for: RichEditorToolbar.self), compatibleWith: nil)

        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.frame.size = dismissButtonSize
        dismissButton.setImage(dismissImage, for: .normal)
        dismissButton.contentHorizontalAlignment = .fill
        dismissButton.contentVerticalAlignment = .fill
        dismissButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.imageView?.contentMode = .scaleAspectFit
        addSubview(dismissButton)

        dismissButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 5).isActive = true
        dismissButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true

        addSubview(toolbarStackView)
        updateToolbar()
    }

    private func updateToolbar() {
        for arrangedSubview in toolbarStackView.arrangedSubviews {
            toolbarStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }

            if let image = option.image {
                let button = RichBarButton(image: image, handler: handler)
                toolbarStackView.addArrangedSubview(button)
            }
        }

        gradientView.frame.origin = frame.origin
        gradientView.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: gradientHeight))

        backingView.frame = CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y + gradientHeight), size: CGSize(width: frame.width, height: frame.height - gradientHeight))
        toolbarStackView.frame.size.width = frame.size.width

        toolbarStackView.frame.size.height = toolbarHeight
        toolbarStackView.frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y + dismissButtonSize.width + dismissButtonInset)
    }
}

final class GradientView: UIView {
    // MARK: -
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        finishInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInit()
    }

    fileprivate func finishInit() {
        isOpaque = false
        backgroundColor = UIColor.clear
    }

    // MARK: -
    // MARK: UIView
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [
            1, 1, 1, 0.00,
            1, 1, 1, 1.00
        ]
        let locations: [CGFloat] = [
            0.0, 1.0
        ]
        let numberOfLocations = 2
        guard let gradient = CGGradient(colorSpace: colorspace, colorComponents: components, locations: locations, count: numberOfLocations) else {
            print("Unable to allocate gradient")
            return
        }
        context?.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: bounds.maxY), options: [])
    }
}
