//
//  ViewController.swift
//  SauceClip_iOS
//
//  Created by banwith7 on 03/18/2024.
//  Copyright (c) 2024 banwith7. All rights reserved.
//

import UIKit
import SauceClip_iOS

class ViewController: UIViewController, UITextFieldDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let urlTextField = UITextField()
    private var checkBoxes = [UIButton]()
    private let openWebViewButton = UIButton()
    private var selectedMessageHandlers = [MessageHandlerName]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupUI()
        setupCheckBoxes()
        setupGestureToHideKeyboard()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // ScrollView 설정
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // ScrollView 제약 조건 설정
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // URL Text Field 설정
        contentView.addSubview(urlTextField)
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Enter URL here"
        urlTextField.delegate = self
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Open WebView Button 설정
        contentView.addSubview(openWebViewButton)
        openWebViewButton.setTitle("Open Web View", for: .normal)
        openWebViewButton.backgroundColor = .systemBlue
        openWebViewButton.addTarget(self, action: #selector(openWebViewController), for: .touchUpInside)
        openWebViewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            openWebViewButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -100), // 위치 조정
            openWebViewButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            openWebViewButton.heightAnchor.constraint(equalToConstant: 50),
            openWebViewButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    private func setupCheckBoxes() {
        let messageHandlerNames: [MessageHandlerName] = [.enter, .exit, .moveCart, .moveProduct, .onShare]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: openWebViewButton.topAnchor, constant: -20)
        ])
        
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
    
    private var handlerStates: [MessageHandlerName: Bool] = [
        .enter: false,
        .exit: false,
        .moveProduct: false,
        .onShare: false,
        .moveCart: false
    ]
    
    @objc private func toggleCheckBox(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
              let selectedName = MessageHandlerName(rawValue: title) else { return }
        
        let isEnabled = handlerStates[selectedName] ?? false
        handlerStates[selectedName] = !isEnabled
        
        sender.layer.borderWidth = !isEnabled ? 2 : 0
        sender.layer.borderColor = !isEnabled ? UIColor.systemBlue.cgColor : nil
        sender.setTitleColor(!isEnabled ? .systemBlue : .black, for: .normal)
    }
    
    @objc private func openWebViewController() {
        guard let urlString = urlTextField.text, urlString.count != 0 else {
            return
        }
        
        let sauceViewController = SauceViewController()
        sauceViewController.urlString = urlString
        sauceViewController.handlerStates = handlerStates
        sauceViewController.modalPresentationStyle = .fullScreen
        self.present(sauceViewController, animated: true)
    }
    
    private func setupGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

