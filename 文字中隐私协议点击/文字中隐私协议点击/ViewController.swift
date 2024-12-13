import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 创建自定义 TextView
        let textView = CustomTextView()
        textView.isEditable = false // 禁止编辑
        textView.isScrollEnabled = false // 禁止滚动
        textView.textContainerInset = .zero // 去除内边距
        textView.backgroundColor = .cyan
        textView.delegate = self
        
        // 设置文本内容和样式
        let text = "尊敬的用户，感谢您信任并使用Eynamics。为保障您的权利，在使用我们的产品和服务前，请您仔细阅读《服务协议》和《隐私政策》的全部条款，您同意并接受全部条款后开始使用我们的服务"
        let attributedString = NSMutableAttributedString(string: text)
        
        // 用户协议范围
        let userAgreementRange = (text as NSString).range(of: "《服务协议》")
        attributedString.addAttribute(.link, value: "userAgreement://", range: userAgreementRange)
        
        // 隐私协议范围
        let privacyPolicyRange = (text as NSString).range(of: "《隐私政策》")
        attributedString.addAttribute(.link, value: "privacyPolicy://", range: privacyPolicyRange)
        
        // 设置富文本
        textView.attributedText = attributedString
        
        // 自定义链接样式
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.blue, // 链接文字颜色
            .underlineStyle: NSUnderlineStyle.single.rawValue // 下划线样式
        ]
        
        // 添加到视图并设置布局
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    // UITextViewDelegate - 点击链接处理
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "userAgreement" {
            print("点击了用户协议")
            

//            showAlert(title: "用户协议", message: "打开用户协议内容")
        } else if URL.scheme == "privacyPolicy" {
            print("点击了隐私协议")
            let vc = ViewController2()
            self.navigationController?.pushViewController(vc, animated: true)
//            showAlert(title: "隐私协议", message: "打开隐私协议内容")
        }
        return false // 禁止系统默认处理
    }
    
    // 辅助方法：显示弹窗
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// 自定义 TextView 禁用选择和长按
class CustomTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 禁止所有弹窗操作
        return false
    }
    
    override var selectedTextRange: UITextRange? {
        get { return nil } // 禁用文本选择
        set { /* 不做任何操作 */ }
    }
    
    // 禁用手势处理器
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // 排除选择和长按手势
        if gestureRecognizer is UILongPressGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
}
