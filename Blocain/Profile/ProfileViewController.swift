//
//  ProfileViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var contentProvider: ProfileViewControllerContentProviderProtocol?
    var actionHandler: ProfileViewControllerActionHandlerProtocol?
    private let topBar = UIView()
    private let titleLabel = UILabel()
    
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(contentProvider: ProfileViewControllerContentProviderProtocol, actionHandler: ProfileViewControllerActionHandlerProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
     
        contentProvider.add(self)
        contentProvider.refresh()
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white

        topBar.backgroundColor = .white
        topBar.layer.shadowColor = UIColor(red: 118 / 255.0, green: 118 / 255.0, blue: 118 / 255.0, alpha: 0.08).cgColor
        topBar.layer.shadowRadius = 9.0
        topBar.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        topBar.layer.shadowOpacity = 1.0
        view.addSubview(topBar)

        titleLabel.text = "My favourite"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        topBar.addSubview(titleLabel)
        
        tableView.separatorStyle = .none
        tableView.register(NewsTableViewCell.classForCoder(), forCellReuseIdentifier: NewsTableViewCell.defaultIdentifier)
        tableView.register(EmptyFavouriteTableViewCell.classForCoder(), forCellReuseIdentifier: EmptyFavouriteTableViewCell.defaultIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        loadContent()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentProvider?.refresh()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0)
        
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
        titleLabel.frame = CGRect(x: (topBar.bounds.width - titleLabelSize.width) / 2.0, y: (topBar.bounds.height - 20.0 - titleLabelSize.height) / 2.0 + 20.0, width: titleLabelSize.width, height: titleLabelSize.height)
        
        tableView.frame = CGRect(x: 0, y: 66.0, width: view.bounds.width, height: view.bounds.size.height - 64.0)
    }
    
    
    private func loadContent() {
        tableView.showsVerticalScrollIndicator = (contentProvider?.content.newsFavouriteDataModelsArray.count != 0)
        tableView.isScrollEnabled = (contentProvider?.content.newsFavouriteDataModelsArray.count != 0)
        tableView.reloadData()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ProfileViewController: CIContentProviderListener {
    func contentProviderDidChangeContent(_ contentProvider: CIContentProviderProtocol!) {
        if isViewLoaded {
            loadContent()
        }
    }
    
    
    func contentProviderDidError(_ contentProvider: CIContentProviderProtocol!) {
        
    }
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(contentProvider?.content.newsFavouriteDataModelsArray.count ?? 0, 1)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if contentProvider?.content.newsFavouriteDataModelsArray.count == 0 {
            let cell = EmptyFavouriteTableViewCell()
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.defaultIdentifier, for: indexPath) as! NewsTableViewCell
            guard let viewModelsArray = contentProvider?.content.newsTableViewCellViewModelsArray else { return cell }
            
            cell.loadViewModel(viewModelsArray[indexPath.row])
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contentProvider?.didWantToUnFavourite(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if contentProvider?.content.newsFavouriteDataModelsArray.count == 0 {
            return tableView.bounds.height
        }else {
            guard let viewModelsArray = contentProvider?.content.newsTableViewCellViewModelsArray else { return 0.0 }
            
            let viewModel = viewModelsArray[indexPath.row]
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
            titleLabel.textAlignment = .left
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.numberOfLines = !viewModel.shouldShowImage ? 3 : 5
            
            if viewModel.shouldShowImage {
                titleLabel.frame.size = CGSize(width: self.view.bounds.width - 20 - 9 - 110 - 16, height: 300)
            }else {
                titleLabel.frame.size = CGSize(width: self.view.bounds.width - 40, height: 300)
            }
            
            titleLabel.text = viewModel.title
            
            titleLabel.sizeToFit()
            
            return titleLabel.frame.height + 8 + 14 + 20 + 8 + 18 + 20
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actionHandler?.actionHandlerDidTapCell(at: indexPath.row)
    }
    
}
