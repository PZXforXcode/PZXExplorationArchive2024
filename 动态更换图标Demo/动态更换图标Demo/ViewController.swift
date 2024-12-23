import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // 创建 UITableView
    var tableView: UITableView!
    
    // 数据源：图标名称
    let icons = [
        "AppIcon",
        "AppIcon 1",
        "AppIcon 2",
        "AppIcon 3",
        "AppIcon 4"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器的标题
        title = "Icons"
        
        // 初始化 UITableView
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "IconCell")
        
        // 添加 UITableView 到视图中
        view.addSubview(tableView)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count // 返回图标的数量
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath)
        let iconName = icons[indexPath.row]
        
        // 配置图标和文字
        cell.textLabel?.text = iconName
        cell.imageView?.image = UIImage(named: iconName) // 设置对应的图标
        cell.imageView?.contentMode = .scaleAspectFit // 确保图标按比例显示
        
        return cell
    }
    
    // MARK: - UITableViewDelegate (可选)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消选中状态
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 打印选中的图标名称
        print("Selected \(icons[indexPath.row])")
        
        let iconName = icons[indexPath.row]
        
        if (iconName == "AppIcon") {
            UIApplication.shared.setAlternateIconName(nil) { error in
                
                if let error = error {
                    print("Error setting alternate icon: \(error.localizedDescription)")
                } else {
                    print("Alternate icon set successfully")
                }
            }
        } else {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                
                if let error = error {
                    print("Error setting alternate icon: \(error.localizedDescription)")
                } else {
                    print("Alternate icon set successfully")
                }
            }
        }
        
 
    }
}
