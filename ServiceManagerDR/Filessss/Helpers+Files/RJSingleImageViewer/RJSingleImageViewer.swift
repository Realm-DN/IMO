import AVFoundation
import UIKit

public final class ANZSingleImageViewer: UIViewController {

    private static let backgroundColor: UIColor = .black
    private static let minZoomLevel: Int = 1
    private static let maxZoomLevel: Int = 4
    private static let padding: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    var image: UIImage? {

        didSet {

            updateImage(image)
        }
    }

    var animator: AnimatedTransitioning?

  //  private static let bundle = Bundle(path: Bundle(for: ANZSingleImageViewer.self).path(forResource: "ANZSingleImageViewer", ofType: "bundle")!)

    private let bg: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        view.image = UIImage(named: "bg_close") //UIImage(named: "menu_close", in: bundle, compatibleWith: nil)
        return view
    }()

 
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(UIImage(named: "icon_close"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()

    private let imageView: UIImageView = {

        let view = UIImageView(frame: .zero)
        return view
    }()

    private let scrollView: UIScrollView = {

        let view = UIScrollView(frame: .zero)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.minimumZoomScale = CGFloat(ANZSingleImageViewer.minZoomLevel)
        view.maximumZoomScale = CGFloat(ANZSingleImageViewer.maxZoomLevel)
        view.contentInset = .zero
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let image = self.image else {
            return
        }

        scrollView.frame = view.frame

        adjustContentSize(image: image, inBoundsSize: scrollView.bounds.size)
        fixButtonPosition()
    }
}

// MARK: - Public
extension ANZSingleImageViewer {

    @discardableResult
    public static func showImage(_ image: UIImage, toParent vc: UIViewController) -> ANZSingleImageViewer {

        let viewer = ANZSingleImageViewer()
        viewer.image = image

        if vc is ANZSingleImageViewerSourceTransitionDelegate {
            let animator = AnimatedTransitioning()
            viewer.animator = animator
        }
        viewer.modalPresentationStyle = .overFullScreen
        vc.present(viewer, animated: true, completion: nil)

        return viewer
    }
}

// MARK: - Private
extension ANZSingleImageViewer {

    private func adjustContentSize(image: UIImage, inBoundsSize size: CGSize) {

        imageView.bounds.size = calcAspectFitSize(
            contentSize: image.size,
            inBoundsSize: size
        )
        scrollView.contentSize = imageView.bounds.size
        imageView.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }

    private func calcAspectFitSize(contentSize size: CGSize, inBoundsSize boundsSize: CGSize) -> CGSize {

        return AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: boundsSize)).size
    }

    private func centerContent(contentSize: CGSize, boundsSize: CGSize) {

        let offsetX = max((boundsSize.width - contentSize.width) * 0.5, 0.0)
        let offsetY = max((boundsSize.height - contentSize.height) * 0.5, 0.0)

        imageView.center = CGPoint(
            x: contentSize.width * 0.5 + offsetX,
            y: contentSize.height * 0.5 + offsetY
        )
    }

    private func dismiss() {

        let minScale = CGFloat(type(of: self).minZoomLevel)

        if animator != nil && scrollView.zoomScale > minScale {

            UIView.animate(withDuration: 0.1, animations: {
                self.scrollView.zoomScale = minScale
            }) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func fixButtonPosition() {

        var padding = type(of: self).padding

        if #available(iOS 11.0, *) {
            padding = UIEdgeInsets(
                top: padding.top + view.safeAreaInsets.top,
                left: padding.left + view.safeAreaInsets.left,
                bottom: padding.bottom + view.safeAreaInsets.bottom,
                right: padding.right + view.safeAreaInsets.right
            )
        }

        button.frame.origin = CGPoint(
            x: view.bounds.width - button.frame.width - padding.right,
            y: padding.top
        )

        bg.center = button.center
       
    }

    private func setup() {

        if let animator = self.animator {
            transitioningDelegate = animator
        } else {
         // modalTransitionStyle = .crossDissolve
            modalPresentationStyle = .overFullScreen
        }

       // modalPresentationCapturesStatusBarAppearance = true

        view.backgroundColor = type(of: self).backgroundColor
        view.addSubview(scrollView)
        view.addSubview(bg)
        view.addSubview(button)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(type(of: self).didDoubleTapView(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        scrollView.addSubview(imageView)

        button.addTarget(self, action: #selector(type(of: self).didTapButton(_:)), for: .touchUpInside)
    }

    private func updateImage(_ image: UIImage?) {

        imageView.image = image
    }

    private func updateZoomScale() {

        let currentScale = Int(scrollView.zoomScale)
        for level in type(of: self).minZoomLevel ..< type(of: self).maxZoomLevel where currentScale == level {
            scrollView.setZoomScale(CGFloat(level + 1), animated: true)
            return
        }

        scrollView.setZoomScale(CGFloat(type(of: self).minZoomLevel), animated: true)
    }
}

// MARK: - Selector
@objc
extension ANZSingleImageViewer {

    private func didDoubleTapView(gesture: UITapGestureRecognizer) {

        updateZoomScale()
    }

    private func didTapButton(_ button: UIButton) {

        dismiss()
    }
}

// MARK: - UIScrollViewDelegate
extension ANZSingleImageViewer: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {

        centerContent(contentSize: scrollView.contentSize, boundsSize: scrollView.bounds.size)
    }
}

// MARK: - ANZSingleImageViewerDestinationTransitionDelegate
extension ANZSingleImageViewer: ANZSingleImageViewerDestinationTransitionDelegate {

    public func viewerBackgroundColor() -> UIColor {

        return type(of: self).backgroundColor
    }

    public func viewerTargetImageView(targetImage image: UIImage?) -> UIImageView {

        if let image = image {
            adjustContentSize(image: image, inBoundsSize: view.bounds.size)
        }

        return imageView
    }
}



//////
///


extension ANZSingleImageViewer {

    final class AnimatedTransitioning: NSObject {

        private static let transitionDuration: TimeInterval = 0.3

        private var isForward: Bool = false
    }
}

// MARK: - Animation
extension ANZSingleImageViewer.AnimatedTransitioning {

    private func animateForward(context: UIViewControllerContextTransitioning) {

        guard
            let fromViewController = context.viewController(forKey: .from),
            let toViewController = context.viewController(forKey: .to)
        else {
            cancelAnimation(context: context)
            return
        }

        let sourceViewController = topViewController(fromViewController)
        let destinationViewController = topViewController(toViewController)

        guard
            let sourceData = sourceViewController as? ANZSingleImageViewerSourceTransitionDelegate,
            let destinationData = destinationViewController as? ANZSingleImageViewerDestinationTransitionDelegate,
            let sourceImageView = sourceData.viewerTargetImageView(),
            let sourceImage = sourceImageView.image
        else {
            cancelAnimation(context: context)
            return
        }

        let containerView = context.containerView
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        let destinationImageView = destinationData.viewerTargetImageView(targetImage: sourceImage)

        let bgView = UIView(frame: containerView.frame)
        bgView.backgroundColor = destinationData.viewerBackgroundColor()
        bgView.alpha = 0.0
        containerView.addSubview(bgView)

        let transitionImageView = UIImageView(image: sourceImage)
        transitionImageView.frame = sourceImageView.convert(sourceImageView.bounds, to: fromViewController.view)
        transitionImageView.contentMode = sourceImageView.contentMode
        containerView.addSubview(transitionImageView)

        sourceImageView.isHidden = true
        destinationViewController.view.isHidden = true

        UIView.animate(withDuration: type(of: self).transitionDuration, delay: .leastNormalMagnitude, options: [.curveEaseOut], animations: {

            bgView.alpha = 1.0
            transitionImageView.contentMode = destinationImageView.contentMode
            transitionImageView.frame = destinationImageView.convert(
                destinationImageView.bounds,
                to: toViewController.view
            )

        }) { (isFinished) in

            destinationViewController.view.isHidden = false
            transitionImageView.removeFromSuperview()
            bgView.removeFromSuperview()
            sourceImageView.isHidden = false

            self.finAnimation(context: context)
        }
    }

    private func animateBack(context: UIViewControllerContextTransitioning) {

        guard
            let fromViewController = context.viewController(forKey: .from),
            let toViewController = context.viewController(forKey: .to)
        else {
            cancelAnimation(context: context)
            return
        }

        let sourceViewController = topViewController(toViewController)
        let destinationViewController = topViewController(fromViewController)

        guard
            let sourceData = sourceViewController as? ANZSingleImageViewerSourceTransitionDelegate,
            let destinationData = destinationViewController as? ANZSingleImageViewerDestinationTransitionDelegate,
            let sourceImageView = sourceData.viewerTargetImageView()
        else {
            cancelAnimation(context: context)
            return
        }

        let containerView = context.containerView
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        let destinationImageView = destinationData.viewerTargetImageView(targetImage: nil)

        let transitionImageView = UIImageView(image: destinationImageView.image)
        transitionImageView.frame = destinationImageView.convert(destinationImageView.bounds, to: fromViewController.view)
        transitionImageView.contentMode = destinationImageView.contentMode
        transitionImageView.clipsToBounds = true
        containerView.addSubview(transitionImageView)

        destinationImageView.isHidden = true
        destinationViewController.view.alpha = 1.0
        sourceImageView.isHidden = true

        UIView.animate(withDuration: type(of: self).transitionDuration, delay: .leastNormalMagnitude, options: [.curveEaseIn], animations: {

            transitionImageView.contentMode = sourceImageView.contentMode
            transitionImageView.frame = sourceImageView.convert(
                sourceImageView.bounds,
                to: toViewController.view
            )
            destinationViewController.view.alpha = 0.0

        }) { (isFinished) in

            sourceImageView.isHidden = false
            transitionImageView.removeFromSuperview()

            self.finAnimation(context: context)
        }
    }

    private func cancelAnimation(context: UIViewControllerContextTransitioning) {

        context.cancelInteractiveTransition()
        context.completeTransition(false)
    }

    private func finAnimation(context: UIViewControllerContextTransitioning) {

        let completed: Bool
        if #available(iOS 10.0, *) {
            completed = true
        } else {
            completed = !context.transitionWasCancelled
        }
        context.completeTransition(completed)
    }
}

// MARK: - Util
extension ANZSingleImageViewer.AnimatedTransitioning {

    private func topViewController(_ viewController: UIViewController) -> UIViewController {

        if let navigationController = viewController as? UINavigationController {
            return topViewController(navigationController.children.last!)
        } else if let tabbarController = viewController as? UITabBarController {
            return topViewController(tabbarController.selectedViewController!)
        } else {
            return viewController
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ANZSingleImageViewer.AnimatedTransitioning: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        isForward = true
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        isForward = false
        return self
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension ANZSingleImageViewer.AnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

        return type(of: self).transitionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if isForward {
            animateForward(context: transitionContext)
        } else {
            animateBack(context: transitionContext)
        }
    }
}



////////


protocol ANZSingleImageViewerDestinationTransitionDelegate {

    func viewerBackgroundColor() -> UIColor
    func viewerTargetImageView(targetImage image: UIImage?) -> UIImageView
}


public protocol ANZSingleImageViewerSourceTransitionDelegate {

    func viewerTargetImageView() -> UIImageView?
}




/////////////////////
///
///
///


//typealias completionRJSingleImageViewer = ((Bool,String)->Void)

public final class RJSingleImageViewer: UIViewController {
    
    private static let backgroundColor: UIColor = .black
    private static let minZoomLevel: Int = 1
    private static let maxZoomLevel: Int = 4
    private static let padding: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    
    var image: UIImage? {
        
        didSet {
            
            updateImage(image)
        }
    }
    var isHideUploadButton : Bool = false
    var completionRJSingleImageViewer :  ((UIImage?)->Void)?
    var animator: AnimatedTransitioning?
    
  //  private static let bundle = Bundle(path: Bundle(for: ANZSingleImageViewer.self).path(forResource: "ANZSingleImageViewer", ofType: "bundle")!)
    
    private let bg: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        view.image = UIImage(named: "bg_close") //UIImage(named: "menu_close", in: bundle, compatibleWith: nil)
        return view
    }()
    
    private let bgUpload: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 30.0))
        view.image = nil  //= UIImage(named: "bg_close") //UIImage(named: "menu_close", in: bundle, compatibleWith: nil)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(UIImage(named: "icon_close"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()
    
    
    private let buttonUpload: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 60, height: 44.0)
//        button.setImage(UIImage(named: "uploadIcon"), for: .normal)
        button.setTitle("Upload", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()
    
    private let imageView: UIImageView = {
        
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private let scrollView: UIScrollView = {
        
        let view = UIScrollView(frame: .zero)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.minimumZoomScale = CGFloat(RJSingleImageViewer.minZoomLevel)
        view.maximumZoomScale = CGFloat(RJSingleImageViewer.maxZoomLevel)
        view.contentInset = .zero
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let image = self.image else {
            return
        }
        
        scrollView.frame = view.frame
        
        adjustContentSize(image: image, inBoundsSize: scrollView.bounds.size)
        fixButtonPosition()
    }
}

// MARK: - Public
extension RJSingleImageViewer {
    
    @discardableResult
    public static func showImage(_ image: UIImage, toParent vc: UIViewController,isHideUploadButton:Bool) -> RJSingleImageViewer {
        
        let viewer = RJSingleImageViewer()
        viewer.image = image
        viewer.isHideUploadButton = isHideUploadButton
        
        if vc is RJSingleImageViewerSourceTransitionDelegate {
            let animator = AnimatedTransitioning()
            viewer.animator = animator
        }
        viewer.modalPresentationStyle = .overFullScreen
        vc.present(viewer, animated: true, completion: nil)
        
        return viewer
    }
}

// MARK: - Private
extension RJSingleImageViewer {
    
    private func adjustContentSize(image: UIImage, inBoundsSize size: CGSize) {
        
        imageView.bounds.size = calcAspectFitSize(
            contentSize: image.size,
            inBoundsSize: size
        )
        scrollView.contentSize = imageView.bounds.size
        imageView.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }
    
    private func calcAspectFitSize(contentSize size: CGSize, inBoundsSize boundsSize: CGSize) -> CGSize {
        
        return AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: boundsSize)).size
    }
    
    private func centerContent(contentSize: CGSize, boundsSize: CGSize) {
        
        let offsetX = max((boundsSize.width - contentSize.width) * 0.5, 0.0)
        let offsetY = max((boundsSize.height - contentSize.height) * 0.5, 0.0)
        
        imageView.center = CGPoint(
            x: contentSize.width * 0.5 + offsetX,
            y: contentSize.height * 0.5 + offsetY
        )
    }
    
    private func dismiss() {
        
        let minScale = CGFloat(type(of: self).minZoomLevel)
        
        if animator != nil && scrollView.zoomScale > minScale {
            
            UIView.animate(withDuration: 0.1, animations: {
                self.scrollView.zoomScale = minScale
            }) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func fixButtonPosition() {
        
        var padding = type(of: self).padding
        
        if #available(iOS 11.0, *) {
            padding = UIEdgeInsets(
                top: padding.top + view.safeAreaInsets.top,
                left: padding.left + view.safeAreaInsets.left,
                bottom: padding.bottom + view.safeAreaInsets.bottom,
                right: padding.right + view.safeAreaInsets.right
            )
        }
        
        buttonUpload.frame.origin = CGPoint(
            x: view.bounds.width - buttonUpload.frame.width - padding.right,
            y: padding.top
        )
        
        button.frame.origin = CGPoint(
            x: padding.left,
            y: padding.top
        )
        
        bg.center = button.center
        bgUpload.center = buttonUpload.center
    }
    
    private func setup() {
        
        if let animator = self.animator {
            transitioningDelegate = animator
        } else {
         // modalTransitionStyle = .crossDissolve
            modalPresentationStyle = .overFullScreen
        }
        
       // modalPresentationCapturesStatusBarAppearance = true
        
        view.backgroundColor = type(of: self).backgroundColor
        view.addSubview(scrollView)
        view.addSubview(bg)
        view.addSubview(button)
        
        if isHideUploadButton == false{
            view.addSubview(bgUpload)
            view.addSubview(buttonUpload)
        }
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(type(of: self).didDoubleTapView(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        buttonUpload.addTarget(self, action: #selector(type(of: self).didTapButtonUpload(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(type(of: self).didTapButton(_:)), for: .touchUpInside)
    }
    
    private func updateImage(_ image: UIImage?) {
        
        imageView.image = image
    }
    
    private func updateZoomScale() {
        
        let currentScale = Int(scrollView.zoomScale)
        for level in type(of: self).minZoomLevel ..< type(of: self).maxZoomLevel where currentScale == level {
            scrollView.setZoomScale(CGFloat(level + 1), animated: true)
            return
        }
        
        scrollView.setZoomScale(CGFloat(type(of: self).minZoomLevel), animated: true)
    }
}

// MARK: - Selector
@objc
extension RJSingleImageViewer {
    
    private func didDoubleTapView(gesture: UITapGestureRecognizer) {
        
        updateZoomScale()
    }
    
    private func didTapButtonUpload(_ button: UIButton) {
        
        dismiss()
        completionRJSingleImageViewer?(self.imageView.image)
    }
    private func didTapButton(_ button: UIButton) {
        
        dismiss()
    }
}

// MARK: - UIScrollViewDelegate
extension RJSingleImageViewer: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        centerContent(contentSize: scrollView.contentSize, boundsSize: scrollView.bounds.size)
    }
}

// MARK: - ANZSingleImageViewerDestinationTransitionDelegate
extension RJSingleImageViewer: RJSingleImageViewerDestinationTransitionDelegate {
    
    public func viewerBackgroundColor() -> UIColor {
        
        return type(of: self).backgroundColor
    }
    
    public func viewerTargetImageView(targetImage image: UIImage?) -> UIImageView {
        
        if let image = image {
            adjustContentSize(image: image, inBoundsSize: view.bounds.size)
        }
        
        return imageView
    }
}



//////
///


extension RJSingleImageViewer {

    final class AnimatedTransitioning: NSObject {
        
        private static let transitionDuration: TimeInterval = 0.3
        
        private var isForward: Bool = false
    }
}

// MARK: - Animation
extension RJSingleImageViewer.AnimatedTransitioning {

    private func animateForward(context: UIViewControllerContextTransitioning) {
        
        guard
            let fromViewController = context.viewController(forKey: .from),
            let toViewController = context.viewController(forKey: .to)
        else {
            cancelAnimation(context: context)
            return
        }
        
        let sourceViewController = topViewController(fromViewController)
        let destinationViewController = topViewController(toViewController)
        
        guard
            let sourceData = sourceViewController as? RJSingleImageViewerSourceTransitionDelegate,
            let destinationData = destinationViewController as? RJSingleImageViewerDestinationTransitionDelegate,
            let sourceImageView = sourceData.viewerTargetImageView(),
            let sourceImage = sourceImageView.image
        else {
            cancelAnimation(context: context)
            return
        }
        
        let containerView = context.containerView
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        let destinationImageView = destinationData.viewerTargetImageView(targetImage: sourceImage)
        
        let bgView = UIView(frame: containerView.frame)
        bgView.backgroundColor = destinationData.viewerBackgroundColor()
        bgView.alpha = 0.0
        containerView.addSubview(bgView)
        
        let transitionImageView = UIImageView(image: sourceImage)
        transitionImageView.frame = sourceImageView.convert(sourceImageView.bounds, to: fromViewController.view)
        transitionImageView.contentMode = sourceImageView.contentMode
        containerView.addSubview(transitionImageView)
        
        sourceImageView.isHidden = true
        destinationViewController.view.isHidden = true
        
        UIView.animate(withDuration: type(of: self).transitionDuration, delay: .leastNormalMagnitude, options: [.curveEaseOut], animations: {
            
            bgView.alpha = 1.0
            transitionImageView.contentMode = destinationImageView.contentMode
            transitionImageView.frame = destinationImageView.convert(
                destinationImageView.bounds,
                to: toViewController.view
            )
            
        }) { (isFinished) in
            
            destinationViewController.view.isHidden = false
            transitionImageView.removeFromSuperview()
            bgView.removeFromSuperview()
            sourceImageView.isHidden = false
            
            self.finAnimation(context: context)
        }
    }
    
    private func animateBack(context: UIViewControllerContextTransitioning) {
        
        guard
            let fromViewController = context.viewController(forKey: .from),
            let toViewController = context.viewController(forKey: .to)
        else {
            cancelAnimation(context: context)
            return
        }
        
        let sourceViewController = topViewController(toViewController)
        let destinationViewController = topViewController(fromViewController)
        
        guard
            let sourceData = sourceViewController as? RJSingleImageViewerSourceTransitionDelegate,
            let destinationData = destinationViewController as? RJSingleImageViewerDestinationTransitionDelegate,
            let sourceImageView = sourceData.viewerTargetImageView()
        else {
            cancelAnimation(context: context)
            return
        }
        
        let containerView = context.containerView
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        let destinationImageView = destinationData.viewerTargetImageView(targetImage: nil)

        let transitionImageView = UIImageView(image: destinationImageView.image)
        transitionImageView.frame = destinationImageView.convert(destinationImageView.bounds, to: fromViewController.view)
        transitionImageView.contentMode = destinationImageView.contentMode
        transitionImageView.clipsToBounds = true
        containerView.addSubview(transitionImageView)

        destinationImageView.isHidden = true
        destinationViewController.view.alpha = 1.0
        sourceImageView.isHidden = true

        UIView.animate(withDuration: type(of: self).transitionDuration, delay: .leastNormalMagnitude, options: [.curveEaseIn], animations: {
            
            transitionImageView.contentMode = sourceImageView.contentMode
            transitionImageView.frame = sourceImageView.convert(
                sourceImageView.bounds,
                to: toViewController.view
            )
            destinationViewController.view.alpha = 0.0

        }) { (isFinished) in

            sourceImageView.isHidden = false
            transitionImageView.removeFromSuperview()

            self.finAnimation(context: context)
        }
    }
    
    private func cancelAnimation(context: UIViewControllerContextTransitioning) {
        
        context.cancelInteractiveTransition()
        context.completeTransition(false)
    }
    
    private func finAnimation(context: UIViewControllerContextTransitioning) {
        
        let completed: Bool
        if #available(iOS 10.0, *) {
            completed = true
        } else {
            completed = !context.transitionWasCancelled
        }
        context.completeTransition(completed)
    }
}

// MARK: - Util
extension RJSingleImageViewer.AnimatedTransitioning {
    
    private func topViewController(_ viewController: UIViewController) -> UIViewController {
        
        if let navigationController = viewController as? UINavigationController {
            return topViewController(navigationController.children.last!)
        } else if let tabbarController = viewController as? UITabBarController {
            return topViewController(tabbarController.selectedViewController!)
        } else {
            return viewController
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension RJSingleImageViewer.AnimatedTransitioning: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isForward = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isForward = false
        return self
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension RJSingleImageViewer.AnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return type(of: self).transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isForward {
            animateForward(context: transitionContext)
        } else {
            animateBack(context: transitionContext)
        }
    }
}



////////


protocol RJSingleImageViewerDestinationTransitionDelegate {
    
    func viewerBackgroundColor() -> UIColor
    func viewerTargetImageView(targetImage image: UIImage?) -> UIImageView
}


public protocol RJSingleImageViewerSourceTransitionDelegate {
    
    func viewerTargetImageView() -> UIImageView?
    
}
