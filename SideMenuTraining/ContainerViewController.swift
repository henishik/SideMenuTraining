//
// Created by Tatsu on 2016-02-14.
// Copyright (c) 2016 Tatsuya Ishikawa. All rights reserved.
//
import UIKit

class ContainerViewController: UIViewController {
    /// Navitation View Controller for main content area
    var mainContentNavigationVC: UINavigationController!
    /// View Controller for main content
    var mainContentVC: MainContentViewController!
    /// View Controller for side menu
    var sideMenuVC: SideMenuViewController!

    /// fixed width of side menu
    let SIDE_MENU_WIDTH: CGFloat = 100
    /// status is side menu is currently open or not
    var isSideMenuOpening = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        /// Construct Main Content are
        constructMainContentVC()
        /// Construct Side Menu
        constructSideMenuVC()

        /// Register Tap Recognizer on main navigation controller view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        mainContentNavigationVC.view.addGestureRecognizer(tapGestureRecognizer)

        /// Register Pan Recognizer on main navigation controller view
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        mainContentNavigationVC.view.addGestureRecognizer(panGestureRecognizer)
    }

    /// Construct Main Content area
    func constructMainContentVC() {
        mainContentVC = MainContentViewController()
        mainContentNavigationVC = UINavigationController(rootViewController: mainContentVC)
        mainContentNavigationVC.navigationBar.barTintColor = UIColor(rgb: 0x303F9F)

        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: "Hamburger"), forState: .Normal)
        toggleButton.frame = CGRectMake(0, 0, 24, 24)
        toggleButton.addTarget(self, action: Selector("toggleSideMenu"), forControlEvents: .TouchUpInside)

        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = toggleButton
        mainContentVC.navigationItem.rightBarButtonItem = rightBarButton

        view.addSubview(mainContentNavigationVC.view)
        addChildViewController(mainContentNavigationVC)
    }

    /// Construct Side Menu
    func constructSideMenuVC() {
        sideMenuVC = SideMenuViewController()
        view.insertSubview(sideMenuVC.view, atIndex: 0)
        sideMenuVC.view.frame = CGRectMake(-SIDE_MENU_WIDTH - 300, 0, SIDE_MENU_WIDTH, view.frame.height)

        addChildViewController(sideMenuVC)
        view.bringSubviewToFront(sideMenuVC.view)
    }

    /// Rotation handling
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if (sideMenuVC != nil) {
            if (isSideMenuOpening) {
                sideMenuVC!.view.frame = CGRectMake(0, 0, SIDE_MENU_WIDTH, view.frame.height)
            } else {
                sideMenuVC!.view.frame = CGRectMake(-SIDE_MENU_WIDTH - 300, 0, SIDE_MENU_WIDTH, view.frame.height)
            }
        }
    }

    /// An action when menu button was clicked
    func toggleSideMenu() {
        if (isSideMenuOpening) {
            animateSideMenu(false)
            isSideMenuOpening = false
        } else {
            if (sideMenuVC == nil) {
                constructSideMenuVC()
            }

            animateSideMenu(true)
            isSideMenuOpening = true
        }
    }

    /**
    Handler to let side menu animate.
    - parameter isOpen: a bool of indicator to open or close side menu.
    */
    func animateSideMenu(isOpen: Bool) {
        if (isOpen) {
            moveSideMenuToXPosition(0)
        } else {
            moveSideMenuToXPosition(-SIDE_MENU_WIDTH)
        }
    }

    /**
    Move side menu.
    - parameter targetPosition: a CGloat that is destination of origin.x for
    side menu to move.
    */
    func moveSideMenuToXPosition(targetPosition: CGFloat) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.sideMenuVC!.view.frame.origin.x = targetPosition
            }, completion:{
            (value: Bool) in
            if (!self.isSideMenuOpening) {
            }
        })
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    /**
    A method that is fired when the tap gesture is recognized on the
    MainContainerViewController.
    - Parameter recognizer: A UITapGestureRecognizer that is
	passed to handle tap gesture.
    */
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        if (isSideMenuOpening) {
            animateSideMenu(false)
            isSideMenuOpening = false
        }
    }

    /**
    A method that is fired when the pan gesture is recognized on the
    MainContainerViewController.
    - Parameter recognizer: A UIPanGestureRecognizer that is
	passed to handle pan gesture.
    */
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        /// Check this is dragging from left to right
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)

        switch (recognizer.state) {
        case .Began:
            if (sideMenuVC == nil) {
                constructSideMenuVC()
            }

            /// Set the Side Menu on default origin.x point
            if (sideMenuVC.view.frame.origin.x < -(SIDE_MENU_WIDTH)) {
                sideMenuVC.view.frame.origin.x = -(SIDE_MENU_WIDTH)
            }

        case .Changed:
            if (gestureIsDraggingFromLeftToRight) {
                if (sideMenuVC!.view.frame.origin.x < 0) {
                    /**
                    Prevent to make a space between left side of the Side menu
                    and lef side of main content.
                    */
                    var amountToMove: CGFloat = 0
                    if (-(sideMenuVC!.view.frame.origin.x) < recognizer.translationInView(view).x) {
                        amountToMove = -(sideMenuVC!.view.frame.origin.x)
                    } else {
                        amountToMove = recognizer.translationInView(view).x
                    }

                    sideMenuVC!.view.center.x = sideMenuVC!.view!.center.x + amountToMove
                    recognizer.setTranslation(CGPointZero, inView: sideMenuVC!.view)
                }
            }

        case .Ended:
            /// Determine if side menu is going to be opened or not by checking
            /// a position of orign.x
            if (sideMenuVC!.view.frame.origin.x < 0) {
                animateSideMenu(false)
                isSideMenuOpening = false
            } else {
                animateSideMenu(true)
                isSideMenuOpening = true
            }

        default:
            break
        }
    }
}

/**
A utility override class to return UIColor by giving rgb as UInt.
- Parameter rbg: A UInt that is target color code as rgb
*/
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
        red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
        )
    }
}
