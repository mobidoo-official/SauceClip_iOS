import UIKit
import SauceClip_iOS

class ViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let clipContainer = UIView()
    private let curationContainer = UIView()
    private var clipCheckBoxes = [UIButton]()
    private var curationCheckBoxes = [UIButton]()
    private let clipOpenClipViewButton = UIButton()
    private let curationOpenCurationViewButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContainers()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // ScrollView 설정, 세이프 영역 내부로 조정
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupContainers() {
        setupContainer(clipContainer, withButton: clipOpenClipViewButton, buttonTitle: "Open ClipView", checkBoxes: &clipCheckBoxes, isTopContainer: true, messageHandlerNames: [.enter, .exit, .moveProduct, .moveCart, .onShare])
        setupContainer(curationContainer, withButton: curationOpenCurationViewButton, buttonTitle: "Open CurationView", checkBoxes: &curationCheckBoxes, isTopContainer: false, messageHandlerNames: [.moveBroadcast])
    }
    
    private func setupContainer(_ container: UIView, withButton button: UIButton, buttonTitle: String, checkBoxes: inout [UIButton], isTopContainer: Bool, messageHandlerNames: [MessageHandlerName]) {
        scrollView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.black.cgColor
        
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(openWebViewController(_:)), for: .touchUpInside)
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: -20),
            
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        if isTopContainer {
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
                // 상단 컨테이너에 대한 추가 제약 조건이 필요하다면 여기에 추가합니다.
                container.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
            ])
        } else {
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: clipContainer.bottomAnchor, constant: 20),
                container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
                container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
                container.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
            ])
        }
        
        setupCheckBoxes(inStackView: stackView, checkBoxes: &checkBoxes, messageHandlerNames: messageHandlerNames)
    }
    
    private func setupCheckBoxes(inStackView stackView: UIStackView, checkBoxes: inout [UIButton], messageHandlerNames: [MessageHandlerName]) {
        messageHandlerNames.enumerated().forEach { (index, name) in
            let button = UIButton(type: .system)
            button.setTitle(name.rawValue, for: .normal)
            button.tag = index
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(toggleCheckBox(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            checkBoxes.append(button)
        }
    }
    
    @objc private func toggleCheckBox(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
              let selectedName = MessageHandlerName(rawValue: title) else { return }
        let isEnabled = handlerStates[selectedName] ?? false
        handlerStates[selectedName] = !isEnabled
        sender.layer.borderWidth = !isEnabled ? 2 : 0
        sender.layer.borderColor = !isEnabled ? UIColor.systemBlue.cgColor : nil
        sender.setTitleColor(!isEnabled ? .systemBlue : .black, for: .normal)
    }
    
    @objc private func openWebViewController(_ sender: UIButton) {
        
        if sender == clipOpenClipViewButton {
            let viewController = SauceViewController()
            viewController.modalPresentationStyle = .fullScreen
            viewController.handlerStates = handlerStates
            present(viewController, animated: true)// ClipViewController는 예시입니다. 실제 클래스에 맞게 수정해주세요.
        } else {
            let viewController = SauceCuraionViewController()
            viewController.modalPresentationStyle = .fullScreen
            viewController.handlerStates = handlerStates
            present(viewController, animated: true)// CurationViewController는 예시입니다. 실제 클래스에 맞게 수정해주세요.
        }
    }
    
    private var handlerStates: [MessageHandlerName: Bool] = [
        .enter: false,
        .exit: false,
        .moveProduct: false,
        .onShare: false,
        .moveCart: false,
        .moveBroadcast: false
    ]
    
}
