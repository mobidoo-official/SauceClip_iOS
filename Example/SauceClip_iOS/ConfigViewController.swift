import UIKit

struct Config {
    static var partnerID = ""
    static var clipID = ""
    static var curationID = ""
    static var stage = false
}

class ConfigViewController: UIViewController {
    
    var titleTextField: UITextField!
    var partnerIDTextField: UITextField!
    var clipIDTextField: UITextField!
    var curationIDTextField: UITextField!
    var checkBox: UISwitch!
    var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "SauceClip"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let partnerIDLabel = UILabel()
        partnerIDLabel.text = "PartnerID"
        partnerIDLabel.font = UIFont.systemFont(ofSize: 16)
        partnerIDLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(partnerIDLabel)
        
        partnerIDTextField = UITextField()
        partnerIDTextField.placeholder = "Enter PartnerID"
        partnerIDTextField.borderStyle = .roundedRect
        partnerIDTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(partnerIDTextField)
        
        let clipIDLabel = UILabel()
        clipIDLabel.text = "ClipID"
        clipIDLabel.font = UIFont.systemFont(ofSize: 16)
        clipIDLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clipIDLabel)
        
        clipIDTextField = UITextField()
        clipIDTextField.placeholder = "Enter ClipID"
        clipIDTextField.borderStyle = .roundedRect
        clipIDTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clipIDTextField)
        
        let curationIDLabel = UILabel()
        curationIDLabel.text = "CurationID"
        curationIDLabel.font = UIFont.systemFont(ofSize: 16)
        curationIDLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(curationIDLabel)
        
        curationIDTextField = UITextField()
        curationIDTextField.placeholder = "Enter CurationID"
        curationIDTextField.borderStyle = .roundedRect
        curationIDTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(curationIDTextField)
        
        checkBox = UISwitch()
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkBox)
        
        let stageLabel = UILabel()
        stageLabel.text = "Stage"
        stageLabel.font = UIFont.systemFont(ofSize: 16)
        stageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stageLabel)
        
        nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.systemBlue, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            partnerIDLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            partnerIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            partnerIDTextField.topAnchor.constraint(equalTo: partnerIDLabel.bottomAnchor, constant: 8),
            partnerIDTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            partnerIDTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clipIDLabel.topAnchor.constraint(equalTo: partnerIDTextField.bottomAnchor, constant: 20),
            clipIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            clipIDTextField.topAnchor.constraint(equalTo: clipIDLabel.bottomAnchor, constant: 8),
            clipIDTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clipIDTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            curationIDLabel.topAnchor.constraint(equalTo: clipIDTextField.bottomAnchor, constant: 20),
            curationIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            curationIDTextField.topAnchor.constraint(equalTo: curationIDLabel.bottomAnchor, constant: 8),
            curationIDTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            curationIDTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            checkBox.topAnchor.constraint(equalTo: curationIDTextField.bottomAnchor, constant: 20),
            checkBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            stageLabel.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor),
            stageLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            
            nextButton.topAnchor.constraint(equalTo: checkBox.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func nextButtonTapped() {
        // Validate text fields
        guard let partnerID = partnerIDTextField.text, !partnerID.isEmpty,
              let clipID = clipIDTextField.text, !clipID.isEmpty,
              let curationID = curationIDTextField.text else {
            // Show alert if any of the text fields is empty
            let alertController = UIAlertController(title: "Error", message: "Please fill in all fields.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let vc = ViewController()
        vc.modalPresentationStyle = .fullScreen
        Config.partnerID = partnerID
        Config.clipID = clipID
        Config.curationID = curationID
        Config.stage = checkBox.isOn
        self.present(vc, animated: true)
        print("Next button tapped!")
    }
}
