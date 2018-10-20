//
//  OnboardingViewController.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/7.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, CIContentProviderListener, TopicsPickerViewDelegate {
    
    private let skipButton = BLButton()
    private let handImageView = UIImageView()
    private let titleLabel = UILabel()
    private let topicsPickerView = TopicsPickerView()
    
    private let contentProvider: OnboardingViewControllerContentProviderProtocol
    
    
    init(contentProvider: OnboardingViewControllerContentProviderProtocol) {
        self.contentProvider = contentProvider
        
        super.init(nibName: nil, bundle: nil)
        
        contentProvider.add(self)
        contentProvider.refresh()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        skipButton.setTitleColor(UIColor(red: 144.0 / 255.0, green: 144.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0), for: .normal)
        skipButton.setTitle("Skip>", for: .normal)
        skipButton.addTarget(self, action: #selector(self.tappedSkipButton), for: .touchUpInside)
        view.addSubview(skipButton)
        
        handImageView.image = UIImage(named: "hello")
        view.addSubview(handImageView)
        
        titleLabel.text = "Welcome to Blocain."
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        titleLabel.textAlignment = .left
        view.addSubview(titleLabel)
        
        topicsPickerView.title = "Pick the topics that you would like to see and read about."
        topicsPickerView.buttonTitle = "Start"
        topicsPickerView.delegate = self
        view.addSubview(topicsPickerView)
        
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        handImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topicsPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32.0).isActive = true
        skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 49.0).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        
        handImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        handImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.size.height * 0.14).isActive = true
        handImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        handImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
     
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: handImageView.bottomAnchor, constant: 3.0).isActive = true
        titleLabel.sizeToFit()
        
        topicsPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topicsPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topicsPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 17.0).isActive = true
        topicsPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
    private func loadContent() {
        topicsPickerView.topicDataModelArray = contentProvider.content.topicDataModelArray
    }
    
    
    private func markAsShown() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "hasShownOnboarding")
        userDefaults.synchronize()
    }
    
    
    @objc func tappedSkipButton() {
        TopicManager.sharedManager.saveOriginalTopics()
        markAsShown()
        contentProvider.tappedActionButton(actionButtonType: .skip)
    }
    
    
    func tappedDoneButton() {
        markAsShown()
        contentProvider.tappedActionButton(actionButtonType: .start)
    }
    
    
    // MARK: CIContentProviderListener
    
    
    func contentProviderDidChangeContent(_ contentProvider: CIContentProviderProtocol!) {
        if isViewLoaded {
            loadContent()
        }
    }
    
    
    func contentProviderDidError(_ contentProvider: CIContentProviderProtocol!) {
        
    }
}
