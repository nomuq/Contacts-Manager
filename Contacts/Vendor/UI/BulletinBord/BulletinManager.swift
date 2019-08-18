/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * An object that manages the presentation of a bulletin.
 *
 * You create a bulletin manager using the `init(rootItem:)` initializer, where `rootItem` is the
 * first bulletin item to display.
 *
 * The manager works like a navigation controller. You can push new items to the stack to display them
 * and pop existing ones to go back.
 *
 * You must call the `prepare` method before displaying the view controller.
 *
 * `BulletinManager` must only be used from the main thread.
 */

@objc public final class BulletinManager: NSObject {

    var viewController: BulletinViewController!

    // MARK: - Configuration

    /**
     * The style of the view covering the content. Defaults to `.dimmed`.
     *
     * Set this value before calling `prepare`. Changing it after will have no effect.
     */

    @objc public var backgroundViewStyle: BulletinBackgroundViewStyle = .dimmed


    // MARK: - Private Properties
    
    private let rootItem: BulletinItem

    private var itemsStack: [BulletinItem]
    private var currentItem: BulletinItem
    private var previousItem: BulletinItem?

    private var isPrepared: Bool = false
    private var isPreparing: Bool = false


    // MARK: - Initialization

    /**
     * Creates a bulletin manager with the first item to display. An item represents the contents
     * displayed on a single card.
     *
     * - parameter rootItem: The first item to display.
     */

    @objc public init(rootItem: BulletinItem) {

        self.rootItem = rootItem
        self.itemsStack = []
        self.currentItem = rootItem

    }

    @available(*, unavailable, message: "BulletinManager.init is unavailable. Use init(rootItem:) instead.")
    override init() {
        fatalError("BulletinManager.init is unavailable. Use init(rootItem:) instead.")
    }

    // MARK: - Interacting with the Bulletin

    /**
     * Performs an operation with the bulletin content view and returns the result.
     *
     * Use this as an opportunity to customize the behavior of the content view (e.g. add motion effects).
     *
     * You must not store a reference to the view, or modify its layout (add subviews, add contraints, ...) as this
     * could break the bulletin.
     *
     * Use this feature sparingly.
     */

    @discardableResult
    public func withContentView<Result>(_ transform: (UIView) throws -> Result) rethrows -> Result {
        return try transform(viewController.contentView)
    }

    /**
     * Prepares the bulletin interface and displays the root item.
     *
     * This method must be called before any other interaction with the bulletin.
     */

    @objc public func prepare() {

        assertIsMainThread()

        viewController = BulletinViewController()
        viewController.manager = self

        viewController.modalPresentationStyle = .overFullScreen
        viewController.transitioningDelegate = viewController
        viewController.loadBackgroundView()

        isPrepared = true
        isPreparing = true

        displayCurrentItem()
        isPreparing = false

    }

    /**
     * Hides the contents of the stack and displays a black activity indicator view.
     *
     * Use this method if you need to perform a long task or fetch some data before changing the item.
     *
     * Displaying the loading indicator does not change the height of the page or the current item.
     *
     * Call one of `push(item:)`, `popItem` or `popToRootItem` to hide the activity indicator and change the current item.
     */

    @objc public func displayActivityIndicator() {

        assertIsPrepared()
        assertIsMainThread()

        precondition(Thread.isMainThread, "BulletinManager must only be used from the main thread.")
        precondition(isPrepared, "You must call the `prepare` function before interacting with the bulletin.")

        viewController.displayActivityIndicator()

    }

    /**
     * Displays a new item after the current one.
     * - parameter item: The item to display.
     */

    @objc public func push(item: BulletinItem) {

        assertIsPrepared()
        assertIsMainThread()

        previousItem = currentItem
        itemsStack.append(item)

        currentItem = item
        displayCurrentItem()

    }

    /**
     * Removes the current item from the stack and displays the previous item.
     */

    @objc public func popItem() {

        assertIsPrepared()
        assertIsMainThread()

        guard let previousItem = itemsStack.popLast() else {
            popToRootItem()
            return
        }

        self.previousItem = previousItem

        guard let currentItem = itemsStack.last else {
            popToRootItem()
            return
        }

        self.currentItem = currentItem
        displayCurrentItem()

    }

    /**
     * Removes all the items from the stack and displays the root item.
     */

    @objc public func popToRootItem() {

        assertIsPrepared()
        assertIsMainThread()

        guard currentItem !== rootItem else {
            return
        }

        previousItem = currentItem
        currentItem = rootItem

        itemsStack = []

        displayCurrentItem()

    }

    /**
     * Displays the next item, if the `nextItem` property of the current item is set.
     *
     * - warning: If you call this method but `nextItem` is `nil`, this will crash your app.
     */

    @objc public func displayNextItem() {

        guard let nextItem = currentItem.nextItem else {
            preconditionFailure("Calling BulletinManager.displayNextItem, but the current item has no nextItem.")
        }

        push(item: nextItem)

    }

    // MARK: - Presentation / Dismissal

    /**
     * Presents the bulletin above the specified view controller.
     *
     * - parameter presentingVC: The view controller to use to present the bulletin.
     * - parameter animated: Whether to animate presentation. Defaults to `true`.
     * - parameter completion: An optional block to execute after presentation. Default to `nil`.
     */

    @objc(presentBulletinAboveViewController:animated:completion:)
    public func presentBulletin(above presentingVC: UIViewController,
                                      animated: Bool = true,
                                      completion: (() -> Void)? = nil) {

        assertIsPrepared()
        assertIsMainThread()

        viewController.modalPresentationCapturesStatusBarAppearance = true
        presentingVC.present(viewController, animated: animated, completion: completion)

    }

    /**
     * Dismisses the bulletin and clears the current page. You will have to call `prepare` before
     * presenting the bulletin again.
     *
     * This method will call the `dismissalHandler` block of the current item if it was set.
     *
     * - parameter animated: Whether to animate dismissal. Defaults to `true`.
     */

    @objc(dismissBulletinAnimated:)
    public func dismissBulletin(animated: Bool = true) {

        assertIsPrepared()
        assertIsMainThread()

        currentItem.tearDown()
        currentItem.manager = nil

        viewController.dismiss(animated: animated) {
            self.completeDismissal()
        }

        isPrepared = false

    }

    /**
     * Tears down the view controller and item stack after dismissal is finished.
     */

    @nonobjc func completeDismissal() {

        currentItem.dismissalHandler?(currentItem)

        for arrangedSubview in viewController.contentStackView.arrangedSubviews {
            viewController.contentStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        viewController.backgroundView = nil
        viewController.manager = nil
        viewController.transitioningDelegate = nil

        viewController = nil

        currentItem = self.rootItem
        tearDownItemsChain(startingAt: self.rootItem)

        for item in itemsStack {
            tearDownItemsChain(startingAt: item)
        }

        itemsStack.removeAll()

    }

    // MARK: - Transitions

    /// Displays the current item.
    private func displayCurrentItem() {

        viewController.isDismissable = false
        viewController.refreshSwipeInteractionController()

        // Tear down old item

        let oldArrangedSubviews = viewController.contentStackView.arrangedSubviews

        previousItem?.tearDown()
        previousItem?.manager = nil
        previousItem = nil

        currentItem.manager = self

        // Create new views

        let newArrangedSubviews = currentItem.makeArrangedSubviews()

        for arrangedSubview in newArrangedSubviews {
            arrangedSubview.isHidden = isPreparing ? false : true
            viewController.contentStackView.addArrangedSubview(arrangedSubview)
        }

        // Animate transition

        let animationDurationFactor: Double = isPreparing ? 0 : 1

        let initialAlphaAnimationDuration = 0.25 * animationDurationFactor

        let initialAlphaAnimations = {

            self.viewController.hideActivityIndicator()

            for arrangedSubview in oldArrangedSubviews {
                arrangedSubview.alpha = 0
            }

            for arrangedSubview in newArrangedSubviews {
                arrangedSubview.alpha = 0
            }

        }

        let transitionAnimationDuration = 0.25 * animationDurationFactor

        let transitionAnimation = {

            for arrangedSubview in oldArrangedSubviews {
                arrangedSubview.isHidden = true
            }

            for arrangedSubview in newArrangedSubviews {
                arrangedSubview.isHidden = false
            }

        }

        let finalAlphaAnimationDuration = 0.25 * animationDurationFactor

        let finalAlphaAnimation = {

            for arrangedSubview in newArrangedSubviews {
                arrangedSubview.alpha = 1
            }

        }

        UIView.animate(withDuration: initialAlphaAnimationDuration, animations: initialAlphaAnimations) { _ in

            UIView.animate(withDuration: transitionAnimationDuration, animations: transitionAnimation) { _ in

                self.viewController.contentStackView.alpha = 1

                UIView.animate(withDuration: finalAlphaAnimationDuration, animations: finalAlphaAnimation) { _ in

                    self.viewController.isDismissable = self.currentItem.isDismissable

                    for arrangedSubview in oldArrangedSubviews {
                        self.viewController.contentStackView.removeArrangedSubview(arrangedSubview)
                        arrangedSubview.removeFromSuperview()
                    }

                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, newArrangedSubviews.first)
                    
                }

            }

        }

    }

    /// Tears down every item on the stack starting from the specified item.
    private func tearDownItemsChain(startingAt item: BulletinItem) {

        item.tearDown()
        item.manager = nil

        if let nextItem = item.nextItem {
            tearDownItemsChain(startingAt: nextItem)
        }

    }

    // MARK: - Utilities

    private func assertIsMainThread() {
        precondition(Thread.isMainThread, "BulletinManager must only be used from the main thread.")
    }

    private func assertIsPrepared() {
        precondition(isPrepared, "You must call the `prepare` function before interacting with the bulletin.")
    }

}
