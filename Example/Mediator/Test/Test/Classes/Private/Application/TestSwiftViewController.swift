//
//  TestSwiftViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestSwiftViewController: TestViewController, TableViewControllerProtocol {
    override func renderNavbar() {
        fw.setRightBarItem("Popup") { _ in
            let viewController = SwiftTestPopupViewController()
            Router.present(viewController, animated: true)
        }
    }
    
    override func renderData() {
        tableData.addObjects(from: [
            "FWViewController",
            "FWCollectionViewController",
            "FWScrollViewController",
            "FWTableViewController",
            "FWWebViewController",
        ])
        
        if #available(iOS 13.0, *) {
            tableData.add("SwiftUIViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.fw.cell(tableView: tableView)
        let value = tableData.object(at: indexPath.row) as? String
        cell.textLabel?.text = value
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var viewController: UIViewController? = nil
        switch indexPath.row {
        case 1:
            viewController = SwiftTestCollectionViewController()
        case 2:
            viewController = SwiftTestScrollViewController()
        case 3:
            viewController = SwiftTestTableViewController()
        case 4:
            viewController = SwiftTestWebViewController()
        default:
            if #available(iOS 13.0, *) {
                if indexPath.row == 5 {
                    viewController = TestSwiftUIViewController()
                } else {
                    viewController = SwiftTestViewController()
                }
            } else {
                viewController = SwiftTestViewController()
            }
        }
        viewController?.navigationItem.title = tableData.object(at: indexPath.row) as? String
        navigationController?.pushViewController(viewController!, animated: true)
    }
}

@objcMembers class SwiftTestViewController: UIViewController, ViewControllerProtocol {
    func renderState(_ state: ViewControllerState, with object: Any?) {
        switch state {
        case .success:
            view.fw.showEmptyView(text: object as? String)
        case .failure:
            view.fw.showEmptyView(text: (object as? NSError)?.localizedDescription, detail: nil, image: nil, action: "重新加载") { [weak self] (sender) in
                self?.view.fw.hideEmptyView()
                
                self?.renderState(.loading, with: nil)
            }
        case .loading:
            view.fw.showLoading(text: "开始加载")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.view.fw.hideLoading()
                
                if [0, 1].randomElement() == 1 {
                    self?.renderState(.success, with: "加载成功")
                } else {
                    self?.renderState(.failure, with: NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "加载失败"]))
                }
            }
        case .ready:
            view.backgroundColor = Theme.backgroundColor
            renderState(.loading, with: nil)
        default:
            break;
        }
    }
}

@objcMembers class SwiftTestCollectionViewController: UIViewController, CollectionViewControllerProtocol, CollectionViewDelegateFlowLayout {
    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.layer.masksToBounds = true
        return contentView
    }()
    
    lazy var flowLayout: CollectionViewFlowLayout = {
        let flowLayout = CollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = .zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.columnCount = 4
        flowLayout.rowCount = 3
        return flowLayout
    }()
    
    func renderCollectionViewLayout() -> UICollectionViewLayout {
        return flowLayout
    }
    
    func renderCollectionView() {
        view.backgroundColor = Theme.backgroundColor
        collectionView.backgroundColor = Theme.tableColor
        collectionView.isPagingEnabled = true
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "view")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "view")
    }
    
    func renderCollectionLayout() {
        view.addSubview(contentView)
        contentView.fw.layoutChain.edges(excludingEdge: .bottom).height(200)
        
        collectionView.removeFromSuperview()
        contentView.addSubview(collectionView)
        collectionView.fw.layoutChain.edges(excludingEdge: .bottom).height(200)
    }
    
    func renderModel() {
        fw.setRightBarItem(UIBarButtonItem.SystemItem.refresh.rawValue) { [weak self] (sender) in
            guard let self = self else { return }
            
            self.flowLayout.itemRenderVertical = !self.flowLayout.itemRenderVertical
            self.collectionView.reloadData()
        }
    }
    
    func renderData() {
        for _ in 0 ..< 18 {
            collectionData.add(UIColor.fw.randomColor)
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flowLayout.itemRenderCount(collectionData.count)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var label = cell.contentView.viewWithTag(100) as? UILabel
        if label == nil {
            let textLabel = UILabel.fw.label(font: .systemFont(ofSize: 16), textColor: .white)
            label = textLabel
            textLabel.tag = 100
            cell.contentView.addSubview(textLabel)
            textLabel.fw.layoutChain.center()
        }
        if indexPath.item < collectionData.count {
            label?.text = "\(indexPath.section) : \(indexPath.item)"
        } else {
            label?.text = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "view", for: indexPath)
        view.backgroundColor = UIColor.fw.randomColor
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, configForSectionAt section: Int) -> CollectionViewSectionConfig? {
        let sectionConfig = CollectionViewSectionConfig()
        sectionConfig.backgroundColor = UIColor.fw.randomColor
        return sectionConfig
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (FW.screenWidth - 40) / 4, height: indexPath.item % 3 == 0 ? 80 : 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 40, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 40, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < collectionData.count {
            view.fw.showMessage(text: "点击section: \(indexPath.section) item: \(indexPath.item)")
        }
    }
    
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetTotal = FWClamp(0, scrollView.fwContentOffsetX / FWScreenWidth, 3)
        let offsetPercent = offsetTotal - CGFloat(Int(offsetTotal))
        var contentHeight: CGFloat = 0
        if Int(offsetTotal) % 2 == 0 {
            contentHeight = 200 - (120 * offsetPercent)
        } else {
            contentHeight = 80 + (120 * offsetPercent)
        }
        contentView.fw.layoutChain.height(contentHeight)
    }*/
}

@objcMembers class SwiftTestScrollViewController: UIViewController, ScrollViewControllerProtocol {
    func renderScrollView() {
        let view = UIView()
        view.backgroundColor = UIColor.fw.randomColor
        contentView.addSubview(view)
        view.fw.layoutMaker { (make) in
            make.edges().height(1000).width(FW.screenWidth)
        }
    }
}

@objcMembers class SwiftTestTableViewController: UIViewController, TableViewControllerProtocol {
    func renderTableView() {
        view.backgroundColor = Theme.backgroundColor
    }
    
    func renderData() {
        tableData.addObjects(from: [0, 1, 2])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

@objcMembers class SwiftTestWebViewController: UIViewController, WebViewControllerProtocol {
    var webItems: NSArray? = {
        return [
            Icon.backImage as Any,
            Icon.closeImage as Any
        ]
    }()
    
    func renderWebView() {
        webRequest = "http://kvm.wuyong.site/test.php"
    }
}

@objcMembers class SwiftTestPopupViewController: UIViewController, ViewControllerProtocol {
    // MARK: - Accessor
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.fw.addTapGesture { [weak self] _ in
            self?.fw.close()
        }
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Lifecycle
    func renderInit() {
        modalPresentationStyle = .custom
        fw.navigationBarHidden = true
        fw.setPresentTransition(nil)
    }
    
    func renderView() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        backgroundView.fw.layoutChain
            .edges(excludingEdge: .bottom)
        contentView.fw.layoutChain
            .edges(excludingEdge: .top)
            .top(toViewBottom: backgroundView)
        
        contentView.fw.layoutChain.height(FW.screenHeight / 2.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.fw.setCornerLayer([.topLeft, .topRight], radius: 8)
    }
}
