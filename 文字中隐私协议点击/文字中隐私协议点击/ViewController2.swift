import UIKit

class ViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let frame = CGRect(x: 20, y: 100, width: 300, height: 160)
        let font = UIFont.boldSystemFont(ofSize: 24)
        // 初始化 PZXClickableLabel
        let clickableLabel = PZXClickableLabel(frame: frame)
        clickableLabel.backgroundColor = .cyan
        view.addSubview(clickableLabel)

        // 配置文本和可点击文字
        let text = "请阅读并同意《用户协议》890890980 和 9098009098《隐私协议》"
        clickableLabel.setupText(text, clickableTexts: ["《用户协议》", "《隐私协议》"])
        
        clickableLabel.setupTextWithStyle(text,
                                 font: font,
                                 textColor: .darkGray,
                                 clickableTextColor: .red,
                                          underlineStyle: .single,
                                 clickableTexts: ["《用户协议》", "《隐私协议》"])
        


        // 设置点击回调
        clickableLabel.onTextTap = { identifier in
            if identifier == "《用户协议》" {
                print("跳转到用户协议页面")
            } else if identifier == "《隐私协议》" {
                print("跳转到隐私协议页面")
            } else {
                print("其他")
            }
        }


   
    }
}
