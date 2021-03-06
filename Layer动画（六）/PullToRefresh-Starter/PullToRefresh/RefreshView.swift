

import UIKit
import QuartzCore

// MARK: Refresh View Delegate Protocol
protocol RefreshViewDelegate {
  func refreshViewDidRefresh(refreshView: RefreshView)
}

// MARK: Refresh View
class RefreshView: UIView, UIScrollViewDelegate {
  
  var delegate: RefreshViewDelegate?
  var scrollView: UIScrollView?
  var refreshing: Bool = false
  var progress: CGFloat = 0.0
  
  var isRefreshing = false
  
  let ovalShapeLayer: CAShapeLayer = CAShapeLayer()
  let airplaneLayer: CALayer = CALayer()
  
  init(frame: CGRect, scrollView: UIScrollView) {
    super.init(frame: frame)
    
    self.scrollView = scrollView
    
    //add the background image
    let imgView = UIImageView(image: UIImage(named: "refresh-view-bg.png"))
    imgView.frame = bounds
    imgView.contentMode = .ScaleAspectFill
    imgView.clipsToBounds = true
    addSubview(imgView)
    
    
    ovalShapeLayer.strokeColor = UIColor.whiteColor().CGColor
    ovalShapeLayer.fillColor = UIColor.clearColor().CGColor
    ovalShapeLayer.lineWidth = 4.0
    //虚线，默认为nil
    ovalShapeLayer.lineDashPattern = [2, 3]
    let refreshRadius = frame.size.height/2 * 0.8
    
    ovalShapeLayer.path = UIBezierPath(ovalInRect: CGRect( x: frame.size.width/2 - refreshRadius,
        y: frame.size.height/2 - refreshRadius,
        width: 2 * refreshRadius,
        height: 2 * refreshRadius) ).CGPath
    layer.addSublayer(ovalShapeLayer)
    
    
    
    let airplaneImage = UIImage(named: "airplane.png")!
    airplaneLayer.contents = airplaneImage.CGImage
    airplaneLayer.bounds = CGRect(x: 0.0, y: 0.0, width: airplaneImage.size.width, height: airplaneImage.size.height)
    airplaneLayer.position = CGPoint(x: frame.size.width/2 + frame.size.height/2 * 0.8, y: frame.size.height/2)
    layer.addSublayer(airplaneLayer)
    
    airplaneLayer.opacity = 0.0
    
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Scroll View Delegate methods
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = CGFloat( max(-(scrollView.contentOffset.y + scrollView.contentInset.top), 0.0))
    self.progress = min(max(offsetY / frame.size.height, 0.0), 1.0)
    
    if !isRefreshing {
      redrawFromProgress(self.progress)
    }
  }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && self.progress >= 1.0 {
            delegate?.refreshViewDidRefresh(self)
            beginRefreshing()
        }

    }
  
   
  // MARK: animate the Refresh View
  
  func beginRefreshing() {
    isRefreshing = true
    
    UIView.animateWithDuration(0.3, animations: {
      var newInsets = self.scrollView!.contentInset
      newInsets.top += self.frame.size.height
      self.scrollView!.contentInset = newInsets
    })
    
    
    let strokeStartAnimation = CABasicAnimation( keyPath: "strokeStart")
    strokeStartAnimation.fromValue = -0.5
    strokeStartAnimation.toValue = 1.0
    let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
    strokeEndAnimation.fromValue = 0.0
    strokeEndAnimation.toValue = 1.0
    
    
    let strokeAnimationGroup = CAAnimationGroup()
    strokeAnimationGroup.duration = 1.5
    strokeAnimationGroup.repeatDuration = 5.0
    strokeAnimationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
    ovalShapeLayer.addAnimation(strokeAnimationGroup, forKey: nil)
    
    
    let flightAnimation = CAKeyframeAnimation(keyPath: "position")
    flightAnimation.path = ovalShapeLayer.path
    flightAnimation.calculationMode = kCAAnimationPaced
    
    
    let airplaneOrientationAnimation = CABasicAnimation( keyPath: "transform.rotation")
    airplaneOrientationAnimation.fromValue = 0
   // airplaneOrientationAnimation.toValue = 4 * M_PI
     airplaneOrientationAnimation.toValue = 2 * M_PI
    
    let flightAnimationGroup = CAAnimationGroup()
    flightAnimationGroup.duration = 1.5
    flightAnimationGroup.repeatDuration = 5.0
    //flightAnimationGroup.animations = [flightAnimation]
    flightAnimationGroup.animations = [flightAnimation, airplaneOrientationAnimation]

    airplaneLayer.addAnimation(flightAnimationGroup, forKey: nil)
    
  }
  
  func endRefreshing() {
    
    isRefreshing = false
    
    UIView.animateWithDuration(0.3, delay:0.0, options: .CurveEaseOut ,animations: {
      var newInsets = self.scrollView!.contentInset
      newInsets.top -= self.frame.size.height
      self.scrollView!.contentInset = newInsets
      }, completion: {_ in
        //finished
    })
  }
  
  func redrawFromProgress(progress: CGFloat) {
    
        
        ovalShapeLayer.strokeEnd = progress
        airplaneLayer.opacity = Float(progress)
  }
  
}
