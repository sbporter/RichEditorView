//
//  RichEditorOptionItem.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// A RichEditorOption object is an object that can be displayed in a RichEditorToolbar.
/// This protocol is proviced to allow for custom actions not provided in the RichEditorOptions enum.
public protocol RichEditorOption {

    /// The image to be displayed in the RichEditorToolbar.
    var image: UIImage? { get }

    /// The title of the item.
    /// If `image` is nil, this will be used for display in the RichEditorToolbar.
    var title: String { get }

    /// The action to be evoked when the action is tapped
    /// - parameter editor: The RichEditorToolbar that the RichEditorOption was being displayed in when tapped.
    ///                     Contains a reference to the `editor` RichEditorView to perform actions on.
    func action(_ editor: RichEditorToolbar)
}

/// RichEditorOptionItem is a concrete implementation of RichEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar.
public struct RichEditorOptionItem: RichEditorOption {

    /// The image that should be shown when displayed in the RichEditorToolbar.
    public var image: UIImage?

    /// If an `itemImage` is not specified, this is used in display
    public var title: String

    /// The action to be performed when tapped
    public var handler: ((RichEditorToolbar) -> Void)

    public init(image: UIImage?, title: String, action: @escaping ((RichEditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }
    
    // MARK: RichEditorOption
    
    public func action(_ toolbar: RichEditorToolbar) {
        handler(toolbar)
    }
}

/// RichEditorOptions is an enum of standard editor actions
public enum RichEditorDefaultOption: RichEditorOption {
    case header(Int)
    case bold
    case underline
    case italic
    case orderedList
    case unorderedList
    
    public static let all: [RichEditorDefaultOption] = [
        .header(1), .header(2), .header(3),
        .bold, .italic, .underline,
        orderedList, unorderedList
    ]

    // MARK: RichEditorOption

    public var image: UIImage? {
        var name = ""
        switch self {
        case .header(let h):
            name = "h\(h)"
        case .bold:
            name = "bold"
        case .underline:
            name = "underline"
        case .italic:
            name = "italic"
        case .orderedList:
            name = "ordered_list"
        case .unorderedList:
            name = "unordered_list"
        }
        
        let bundle = Bundle(for: RichEditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var title: String {
        switch self {
        case .header(let h):
            return NSLocalizedString("H\(h)", comment: "")
        case .bold:
            return NSLocalizedString("Bold", comment: "")
        case .underline:
            return NSLocalizedString("Underline", comment: "")
        case .italic:
            return NSLocalizedString("Italic", comment: "")
        case .orderedList:
            return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList:
            return NSLocalizedString("Unordered List", comment: "")
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        switch self {
        case .header(let h):
            toolbar.editor?.header(h)
        case .bold:
            toolbar.editor?.bold()
        case .italic:
            toolbar.editor?.italic()
        case .underline:
            toolbar.editor?.underline()
        case .orderedList:
            toolbar.editor?.orderedList()
        case .unorderedList:
            toolbar.editor?.unorderedList()
        }
    }
}
