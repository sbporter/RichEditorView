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
    
//    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
//        self.init(image: image, style: .plain, target: nil, action: nil)
//        target = self
//        action = #selector(RichBarButton.buttonWasTapped)
//        actionHandler = handler
//    }
//
//    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
//        self.init(title: title, style: .plain, target: nil, action: nil)
//        target = self
//        action = #selector(RichBarButton.buttonWasTapped)
//        actionHandler = handler
//    }

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

    private var toolbarStackView = UIStackView()
    private var dividerLineView = UIView()

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

        toolbarStackView.autoresizingMask = .flexibleWidth
        toolbarStackView.backgroundColor = .clear
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

        toolbarStackView.frame.size.width = frame.size.width

        toolbarStackView.frame.size.height = 44
    }
}
