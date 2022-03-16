import UIKit

final class CheckOverlap {
    func doOverlapEachOther1(view1: UIView, view2: UIView, superview: UIView) -> Bool {
        guard let superview1 = view1.superview,
              let superview2 = view2.superview
        else {
            return false
        }
        
        let frame1 = superview1.convert(view1.frame, to: superview)
        let frame2 = superview2.convert(view2.frame, to: superview)
        
        return frame1.intersects(frame2)
    }
    
    func doOverlapEachOther2(view1: UIView, view2: UIView, superview: UIView) -> Bool {
        guard let superview1 = view1.superview,
              let superview2 = view2.superview
        else {
            return false
        }
        
        let frame1 = superview1.convert(view1.frame, to: superview)
        let frame2 = superview2.convert(view2.frame, to: superview)
        
        return doOverlapByX(frame1: frame1, frame2: frame2) && doOverlapByY(frame1: frame1, frame2: frame2)
    }
    
    func doOverlapEachOther3(view1: UIView, view2: UIView, superview: UIView) -> Bool {
        guard let superview = CommonSuperview().findCommonSuperView(view1: view1, view2: view2) else {
            return false
        }
        
        let frame1 = getFrameFrom(view: view1, superview: superview)
        let frame2 = getFrameFrom(view: view2, superview: superview)
        
        return doOverlapByX(frame1: frame1, frame2: frame2) && doOverlapByY(frame1: frame1, frame2: frame2)
    }
    
    private func getFrameFrom(view: UIView, superview: UIView) -> CGRect {
        let width = view.frame.width
        let height = view.frame.height
        
        var currentView: UIView? = view
        var originX = view.frame.origin.x
        var originY = view.frame.origin.y
        
        while currentView != nil && currentView != superview {
            currentView = currentView?.superview
            if let currentView = currentView {
                originX += currentView.frame.origin.x
                originY += currentView.frame.origin.y
            }
        }
        
        if currentView == nil {
            return CGRect.zero
        }
        else {
            return CGRect(x: originX, y: originY, width: width, height: height)
        }
    }
    
    private func doOverlapByX(frame1: CGRect, frame2: CGRect) -> Bool {
        if frame1.maxX > frame2.maxX {
            // frame2 should be bigger
            return doOverlapByX(frame1: frame2, frame2: frame1)
        }
        else {
            return frame1.maxX > frame2.origin.x
        }
    }
    
    private func doOverlapByY(frame1: CGRect, frame2: CGRect) -> Bool {
        if frame1.maxY > frame2.maxY {
            // frame2 should be bigger
            return doOverlapByX(frame1: frame2, frame2: frame1)
        }
        else {
            return frame1.maxY > frame2.origin.y
        }
    }
}
