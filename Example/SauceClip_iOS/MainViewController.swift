import UIKit

enum buildTarget {
    case stage
    case production
}

enum clipType {
    case player
    case curation
}

class MainViewController: UIViewController {
    
    let partnerIDTextField = UITextField()
    let clipIDTextField = UITextField()
    let curationIDTextField = UITextField()
    let modeSegmentedControl = UISegmentedControl(items: ["Stage", "Production"])
    let viewSegmentedControl = UISegmentedControl(items: ["클립 플레이어", "전시 화면"])
    
    var target: buildTarget = .stage
    var viewType: clipType = .player
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        partnerIDTextField.text = ""
        clipIDTextField.text = ""
        curationIDTextField.text = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        modeSegmentedControl.addTarget(self, action: #selector(targetSegmentChanged(_:)), for: .valueChanged)
        modeSegmentedControl.selectedSegmentIndex = 0
        
        viewSegmentedControl.addTarget(self, action: #selector(viewSegmentChanged(_:)), for: .valueChanged)
        viewSegmentedControl.selectedSegmentIndex = 0
        updateInputFields()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "SauceClip"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let partnerIDLabel = createLabel(text: "파트너 아이디")
        let clipIDLabel = createLabel(text: "클립 아이디")
        let curationIDLabel = createLabel(text: "큐레이션 아이디")
        
        partnerIDTextField.placeholder = "Enter PartnerID (필수)"
        partnerIDTextField.borderStyle = .roundedRect
        partnerIDTextField.translatesAutoresizingMaskIntoConstraints = false
        
        clipIDTextField.placeholder = "Enter ClipID"
        clipIDTextField.borderStyle = .roundedRect
        clipIDTextField.translatesAutoresizingMaskIntoConstraints = false
        
        curationIDTextField.placeholder = "Enter CurationID"
        curationIDTextField.borderStyle = .roundedRect
        curationIDTextField.translatesAutoresizingMaskIntoConstraints = false
        
        modeSegmentedControl.selectedSegmentIndex = 0
        modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        viewSegmentedControl.selectedSegmentIndex = 0
        viewSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            modeSegmentedControl,
            viewSegmentedControl,
            partnerIDLabel,
            partnerIDTextField,
            clipIDLabel,
            clipIDTextField,
            curationIDLabel,
            curationIDTextField
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        let buttonStackView = UIStackView(arrangedSubviews: [
            createButton(title: "이동", action: #selector(goToClipView))
        ])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        let usageLabel = UILabel()
        usageLabel.text = "사용법: 각 입력란에 정보를 입력하고, 원하는 화면으로 이동하세요.\n모드를 선택하여 설정을 변경할 수 있습니다."
        usageLabel.textColor = .gray
        usageLabel.numberOfLines = 0
        usageLabel.textAlignment = .center
        usageLabel.layer.borderColor = UIColor.gray.cgColor
        usageLabel.layer.borderWidth = 1
        usageLabel.layer.cornerRadius = 8
        usageLabel.layer.masksToBounds = true
        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(usageLabel)
        
        NSLayoutConstraint.activate([
            usageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            usageLabel.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20)
        ])
    }
    
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }
    
    @objc func goToClipView() {
        if viewType == .player {
            let clipPlayerVC = ClipPlayerViewController()
            clipPlayerVC.partnerID = partnerIDTextField.text
            clipPlayerVC.clipID = clipIDTextField.text
            clipPlayerVC.curationID = curationIDTextField.text
            clipPlayerVC.isStageMode = (modeSegmentedControl.selectedSegmentIndex == 0)
            navigationController?.pushViewController(clipPlayerVC, animated: true)
        } else {
            let exhibitionVC = ClipCurationViewController()
            exhibitionVC.partnerID = partnerIDTextField.text
            exhibitionVC.curationID = curationIDTextField.text
            exhibitionVC.isStageMode = (modeSegmentedControl.selectedSegmentIndex == 0)
            navigationController?.pushViewController(exhibitionVC, animated: true)
        }
    }
    
    @objc func targetSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            target = .stage
        } else {
            target = .production
        }
        print(target)
    }
    
    @objc func viewSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewType = .player
        } else {
            viewType = .curation
        }
        updateInputFields()
        print(viewType)
    }
    
    func updateInputFields() {
        if viewSegmentedControl.selectedSegmentIndex == 0 {
            clipIDTextField.isEnabled = true
            curationIDTextField.isEnabled = false
        } else {
            clipIDTextField.isEnabled = false
            curationIDTextField.isEnabled = true
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardHeight / 2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
