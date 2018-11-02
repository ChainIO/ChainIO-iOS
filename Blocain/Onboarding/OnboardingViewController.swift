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
    private let subTitleLabel = UILabel()
    private var collectionView: UICollectionView!
    private let doneButton = BLButton()
    
    private var longPressGesture: UILongPressGestureRecognizer!
    
    private let contentProvider: OnboardingViewControllerContentProviderProtocol
    
    var didChangeTopics = false
    var isShowingAlertView = false
    
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
        
        subTitleLabel.text = "Pick the topics that you would like to see and read about."
        subTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        subTitleLabel.textAlignment = .left
        subTitleLabel.numberOfLines = 0
        view.addSubview(subTitleLabel)
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumInteritemSpacing = 12.0
        if view.bounds.height == 667.0 {
            collectionViewFlowLayout.minimumLineSpacing = 33
        }else if view.bounds.height == 736.0 {
            collectionViewFlowLayout.minimumLineSpacing = 27.5
        }else if view.bounds.height == 812.0 {
            collectionViewFlowLayout.minimumLineSpacing = 24
        }else {
            collectionViewFlowLayout.minimumLineSpacing = 26
        }
        
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(5, 30, 5, 30)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TopicsPickerCell.classForCoder(), forCellWithReuseIdentifier: TopicsPickerCell.defaultIdentifier)
        view.addSubview(collectionView)
        
        doneButton.setTitle("Start", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        doneButton.backgroundColor = UIColor(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0)
        doneButton.addTarget(self, action: #selector(self.tappedDoneButton), for: .touchUpInside)
        doneButton.layer.cornerRadius = 27.0
        view.addSubview(doneButton)
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        handImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        subTitleLabel.sizeToFit()
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        collectionView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 48.0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -66.0).isActive = true
        
        doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -56.0).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    
    private func loadContent() {
        collectionView.reloadData()
    }
    
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
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
        let tmpArray = contentProvider.content.topicDataModelArray.filter(){$0.isSelected == true}
        guard tmpArray.count > 0 else {
            showErrorMessage()
            return
        }
        
        TopicManager.sharedManager.saveUserCustomTopics(array: contentProvider.content.topicDataModelArray)
        
        markAsShown()
        contentProvider.tappedActionButton(actionButtonType: .start)
    }
    
    
    private func showErrorMessage() {
        if !isShowingAlertView {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1
            
            let alertViewController = UIAlertController(title: "Error", message: "Please pick at least one topic to get started.", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alertViewController.dismiss(animated: true, completion: {[weak self] in
                    self?.isShowingAlertView = false
                })
            }))
            
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alertViewController, animated: true, completion: nil)
            isShowingAlertView = true
        }
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


extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentProvider.content.topicDataModelArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicsPickerCell.defaultIdentifier, for: indexPath) as! TopicsPickerCell
        cell.setTitleLabelText(contentProvider.content.topicDataModelArray[indexPath.item].name)
        cell.isSelected = contentProvider.content.topicDataModelArray[indexPath.item].isSelected
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = contentProvider.content.topicDataModelArray[sourceIndexPath.item]
        contentProvider.content.topicDataModelArray.remove(at: sourceIndexPath.item)
        contentProvider.content.topicDataModelArray.insert(title, at: destinationIndexPath.item)
        didChangeTopics = true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topicModel = contentProvider.content.topicDataModelArray[indexPath.item]
        topicModel.isSelected = !topicModel.isSelected
        if topicModel.isSelected {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init(rawValue: 0))
        }else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        didChangeTopics = true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tmpLabel = TopicPickerLabel()
        tmpLabel.text = contentProvider.content.topicDataModelArray[indexPath.item].name
        let size = tmpLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40))
        return size
    }
    
}
