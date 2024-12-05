//
//  ViewController.swift
//  DrawerViewControllerDemo
//
//  Created by 彭祖鑫 on 2024/8/20.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var topEdge: NSLayoutConstraint!
    @IBOutlet weak var screenWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .darkGray
        screenWidth.constant = UIScreen.main.bounds.width
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let verticalOffset = scrollView.contentOffset.y
        print("verticalOffset = \(verticalOffset)")
        let absoluteValue = verticalOffset + 180.0
        bottomView.alpha = 1 - ((absoluteValue/180.0) * 3)
//        
        if (verticalOffset >= -180) {
            topEdge.constant = -(verticalOffset + 180) * 0.3
        } else {
            
            topEdge.constant = 0

        }

//        self.view.layoutIfNeeded()
        
    }

}










import UIKit

class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

class ThirdViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}

import UIKit

class PageViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化分页内容视图控制器
        let firstVC = FirstViewController()
        let secondVC = SecondViewController()
        let thirdVC = ThirdViewController()
        pages = [firstVC, secondVC, thirdVC]
        
        // 初始化UIPageViewController
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: nil)
        
        pageViewController.dataSource = self
        
        // 设置第一页
        if let firstVC = pages.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        // 将UIPageViewController添加到当前视图控制器中
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    // 数据源方法，返回前一个视图控制器
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    // 数据源方法，返回后一个视图控制器
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
}


