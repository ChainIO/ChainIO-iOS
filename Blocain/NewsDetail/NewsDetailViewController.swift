//
//  NewsDetailViewController.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/31.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        self.navigationController?.navigationBar.barTintColor = .black
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.tappedBackButton))
        backButtonItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButtonItem
        let bookmarkButton = UIBarButtonItem(image: UIImage(named: "bookmark"), style: .plain, target: self, action: #selector(self.tappedBookmarkButton))
        bookmarkButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = bookmarkButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @objc func tappedBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func tappedBookmarkButton() {
        
    }
}
