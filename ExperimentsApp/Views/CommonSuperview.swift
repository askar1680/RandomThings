import UIKit

final class CommonSuperview {
    func findCommonSuperView(view1: UIView, view2: UIView) -> UIView? {
        let parentView = findSuperView(view: view1)
        let parentView2 = findSuperView(view: view2)
        guard let parentView = parentView,
              let parentView2 = parentView2,
              parentView == parentView2
        else {
            return nil
        }
        
        var level1 = findLevel(parentView: parentView, view: view1)
        var level2 = findLevel(parentView: parentView, view: view2)
        
        var view1Optional: UIView? = view1
        while level1 > level2 {
            level1 -= 1
            view1Optional = view1Optional?.superview
        }
        
        var view2Optional: UIView? = view2
        while level2 > level1 {
            level2 -= 1
            view2Optional = view2Optional?.superview
        }
        
        while view1Optional != view2Optional {
            view1Optional = view1Optional?.superview
            view2Optional = view2Optional?.superview
        }
        
        return view1Optional
    }
    
    private func findLevel(parentView: UIView, view: UIView) -> Int {
        var currentView: UIView? = view
        var level = 0
        while currentView != parentView {
            currentView = currentView?.superview
            level += 1
        }
        return level
    }
    
    private func findSuperView(view: UIView) -> UIView? {
        var currentView: UIView? = view.superview
        var parentView: UIView?
        while currentView != nil {
            parentView = currentView
            currentView = currentView?.superview
        }
        return parentView
    }
}
