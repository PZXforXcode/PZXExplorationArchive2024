import UIKit

class CustomTabBarController: UITabBarController {

    private let customTabBarView = UIView()
    private let buttonTitles = ["Home", "Profile"]
    private let buttonImages = [UIImage(systemName: "house"), UIImage(systemName: "person")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupCustomTabBar()
        hideSystemTabBar()
    }
    
    private func setupViewControllers() {
        let homeVC = UIViewController()
        homeVC.view.backgroundColor = .white
        
        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .lightGray
        
        viewControllers = [homeVC, profileVC]
    }
    
    private func hideSystemTabBar() {
        tabBar.isHidden = true // 隐藏系统 TabBar
    }

    private func setupCustomTabBar() {
        // 自定义 TabBar 的外观
        customTabBarView.backgroundColor = .cyan
        customTabBarView.layer.shadowColor = UIColor.black.cgColor
        customTabBarView.layer.shadowOpacity = 0.1
        customTabBarView.layer.shadowOffset = CGSize(width: 0, height: -3)
        
        view.addSubview(customTabBarView)
        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBarView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        addCustomTabBarButtons()
    }
    
    private func addCustomTabBarButtons() {
        let buttonWidth = UIScreen.main.bounds.width / CGFloat(buttonTitles.count)
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.setImage(buttonImages[index], for: .normal)
            button.tintColor = .gray
            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
            
            // 按钮布局
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: 60)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.imageView?.contentMode = .scaleAspectFit
            
            // 调整图标和文字的间距
            button.titleEdgeInsets = UIEdgeInsets(top: 30, left: -25, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: -30)
            
            customTabBarView.addSubview(button)
        }
    }

    @objc private func tabBarButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateButtonColors(selectedIndex: sender.tag)
    }
    
    private func updateButtonColors(selectedIndex: Int) {
        for (index, button) in customTabBarView.subviews.enumerated() {
            guard let button = button as? UIButton else { continue }
            button.tintColor = index == selectedIndex ? .systemBlue : .gray
        }
    }
}
