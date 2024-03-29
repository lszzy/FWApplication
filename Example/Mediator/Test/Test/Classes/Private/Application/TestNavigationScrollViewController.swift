//
//  TestNavigationScrollViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

class TestNavigationTitleLabel: UILabel, TitleViewProtocol {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title: String? {
        get { return text }
        set { text = newValue }
    }
}

@objcMembers class TestNavigationScrollViewController: TestViewController, TableViewControllerProtocol {
    private lazy var navigationView: ToolbarView = {
        let navigationView = ToolbarView(type: .navBar)
        navigationView.backgroundColor = Theme.barColor
        navigationView.menuView.centerButton = TestNavigationTitleLabel()
        navigationView.menuView.title = "我是很长很长要多长有多长长得不得了的按钮"
        navigationView.menuView.tintColor = Theme.textColor
        let leftButton = ToolbarButton(image: Icon.backImage)
        leftButton.fw.addTouch { sender in
            Router.closeViewController(animated: true)
        }
        navigationView.menuView.leftButton = leftButton
        return navigationView
    }()
    
    override func renderInit() {
        fw.navigationBarHidden = true
    }
    
    override func renderView() {
        tableView.fw.contentInsetAdjustmentNever()
        tableView.fw.pullRefreshHeight = PullRefreshView.height + UIScreen.fw.safeAreaInsets.top
        tableView.fw.setRefreshing(target: self, action: #selector(onRefreshing))
        
        let toolbar = UIToolbar()
        toolbar.fw.barPosition = .bottom
        toolbar.fw.foregroundColor = Theme.textColor
        toolbar.fw.backgroundColor = Theme.barColor
        view.addSubview(toolbar)
        toolbar.fw.layoutChain.edges(toSafeArea: .zero, excludingEdge: .top)
        
        let leftItem = UIBarButtonItem.fw.item(object: "取消", block: nil)
        let flexibleItem = UIBarButtonItem.fw.item(object: NSNumber(value: UIBarButtonItem.SystemItem.flexibleSpace.rawValue), block: nil)
        let rightItem = UIBarButtonItem.fw.item(object: "确定", block: nil)
        toolbar.items = [leftItem, flexibleItem, rightItem]
        toolbar.sizeToFit()
    }
    
    override func renderData() {
        tableData.addObjects(from: [
            "FWViewController",
            "FWCollectionViewController",
            "FWScrollViewController",
            "FWTableViewController",
            "FWWebViewController",
        ])
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return navigationView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return navigationView.toolbarHeight
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
            viewController = SwiftTestViewController()
        }
        viewController?.navigationItem.title = tableData.object(at: indexPath.row) as? String
        navigationController?.pushViewController(viewController!, animated: true)
    }
    
    // MARK: - Action
    @objc func onRefreshing() {
        NSLog("开始刷新")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            NSLog("刷新完成")
            self?.tableView.reloadData()
            self?.tableView.fw.endRefreshing()
        }
    }
}
