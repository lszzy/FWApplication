//
//  UITableView+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2020/10/21.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import UIKit
import FWFramework
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

// MARK: - TableViewDelegate
/// 便捷表格视图代理
@objc(FWTableViewDelegate)
@objcMembers open class TableViewDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    /// 表格数据，可选方式，必须按[section][row]二维数组格式
    open var tableData: [[Any]] = []
    
    /// 表格section数，默认自动计算tableData
    open var countForSection: (() -> Int)?
    /// 表格section数，默认0自动计算，优先级低
    open var sectionCount: Int = 0
    /// 表格row数句柄，默认自动计算tableData
    open var countForRow: ((Int) -> Int)?
    /// 表格row数，默认0自动计算，优先级低
    open var rowCount: Int = 0
    
    /// 表格section头视图句柄，支持UIView或UITableViewHeaderFooterView，默认nil
    open var viewForHeader: ((Int) -> Any?)?
    /// 表格section头视图，支持UIView或UITableViewHeaderFooterView，默认nil，优先级低
    open var headerViewClass: Any?
    /// 表格section头视图配置句柄，参数为headerClass对象，默认为nil
    open var headerConfiguration: HeaderFooterViewSectionBlock?
    /// 表格section头高度句柄，不指定时默认使用FWDynamicLayout自动计算并按section缓存
    open var heightForHeader: ((Int) -> CGFloat)?
    /// 表格section头高度，默认nil自动根据viewModel计算，可设置为automaticDimension，优先级低
    open var headerHeight: CGFloat?
    
    /// 表格section尾视图句柄，支持UIView或UITableViewHeaderFooterView，默认nil
    open var viewForFooter: ((Int) -> Any?)?
    /// 表格section尾视图，支持UIView或UITableViewHeaderFooterView，默认nil，优先级低
    open var footerViewClass: Any?
    /// 表格section头视图配置句柄，参数为headerClass对象，默认为nil
    open var footerConfiguration: HeaderFooterViewSectionBlock?
    /// 表格section尾高度句柄，不指定时默认使用FWDynamicLayout自动计算并按section缓存
    open var heightForFooter: ((Int) -> CGFloat)?
    /// 表格section尾高度，默认nil自动根据viewModel计算，可设置为automaticDimension，优先级低
    open var footerHeight: CGFloat?
    
    /// 表格cell类句柄，style为default，支持cell或cellClass，默认nil
    open var cellForRow: ((IndexPath) -> Any?)?
    /// 表格cell类，支持cell或cellClass，默认nil，优先级低
    open var cellClass: Any?
    /// 表格cell配置句柄，参数为对应cellClass对象，默认设置fwViewModel为tableData对应数据
    open var cellConfiguation: CellIndexPathBlock?
    /// 表格cell高度句柄，不指定时默认使用FWDynamicLayout自动计算并按indexPath缓存
    open var heightForRow: ((IndexPath) -> CGFloat)?
    /// 表格cell高度，默认nil自动根据viewModel计算，可设置为automaticDimension，优先级低
    open var rowHeight: CGFloat?
    
    /// 表格选中事件，默认nil
    open var didSelectRow: ((IndexPath) -> Void)?
    /// 表格删除标题句柄，不为空才能删除，默认nil不能删除
    open var titleForDelete: ((IndexPath) -> String?)?
    /// 表格删除标题，不为空才能删除，默认nil不能删除，优先级低
    open var deleteTitle: String?
    /// 表格删除事件，默认nil
    open var didDeleteRow: ((IndexPath) -> Void)?
    
    // MARK: - UITableView
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let countBlock = countForSection {
            return countBlock()
        }
        if sectionCount > 0 {
            return sectionCount
        }
        
        return tableData.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let countBlock = countForRow {
            return countBlock(section)
        }
        if rowCount > 0 {
            return rowCount
        }
        
        return tableData.count > section ? tableData[section].count : 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowCell = cellForRow?(indexPath) ?? cellClass
        if let cell = rowCell as? UITableViewCell {
            return cell
        }
        guard let clazz = rowCell as? UITableViewCell.Type else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        // 注意：此处必须使用.__fw_创建，否则返回的对象类型不对
        let cell = clazz.__fw_cell(with: tableView)
        if let cellBlock = cellConfiguation {
            cellBlock(cell, indexPath)
            return cell
        }
        
        var viewModel: Any?
        if let sectionData = tableData.count > indexPath.section ? tableData[indexPath.section] : nil,
           sectionData.count > indexPath.row {
            viewModel = sectionData[indexPath.row]
        }
        cell.__fw_viewModel = viewModel
        return cell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let heightBlock = heightForRow {
            return heightBlock(indexPath)
        }
        if let rowHeight = rowHeight {
            return rowHeight
        }
        
        let rowCell = cellForRow?(indexPath) ?? cellClass
        if let cell = rowCell as? UITableViewCell {
            return cell.frame.size.height
        }
        guard let clazz = rowCell as? UITableViewCell.Type else {
            return 0
        }
        
        if let cellBlock = cellConfiguation {
            return tableView.fw.height(cellClass: clazz, cacheBy: indexPath) { (cell) in
                cellBlock(cell, indexPath)
            }
        }
        
        var viewModel: Any?
        if let sectionData = tableData.count > indexPath.section ? tableData[indexPath.section] : nil,
           sectionData.count > indexPath.row {
            viewModel = sectionData[indexPath.row]
        }
        return tableView.fw.height(cellClass: clazz, cacheBy: indexPath) { (cell) in
            cell.__fw_viewModel = viewModel
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewClass = viewForHeader?(section) ?? headerViewClass
        guard let header = viewClass else { return nil }
        
        if let view = header as? UIView {
            return view
        }
        if let clazz = header as? UITableViewHeaderFooterView.Type {
            // 注意：此处必须使用.__fw_创建，否则返回的对象类型不对
            let view = clazz.__fw_headerFooterView(with: tableView)
            let viewBlock = headerConfiguration ?? { (header, section) in header.__fw_viewModel = nil }
            viewBlock(view, section)
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let heightBlock = heightForHeader {
            return heightBlock(section)
        }
        if let headerHeight = headerHeight {
            return headerHeight
        }
        
        let viewClass = viewForHeader?(section) ?? headerViewClass
        guard let header = viewClass else { return 0 }
        
        if let view = header as? UIView {
            return view.frame.size.height
        }
        if let clazz = header as? UITableViewHeaderFooterView.Type {
            let viewBlock = headerConfiguration ?? { (header, section) in header.__fw_viewModel = nil }
            return tableView.fw.height(headerFooterViewClass: clazz, type: .header, cacheBy: section) { (headerView) in
                viewBlock(headerView, section)
            }
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewClass = viewForFooter?(section) ?? footerViewClass
        guard let footer = viewClass else { return nil }
        
        if let view = footer as? UIView {
            return view
        }
        if let clazz = footer as? UITableViewHeaderFooterView.Type {
            // 注意：此处必须使用.__fw_创建，否则返回的对象类型不对
            let view = clazz.__fw_headerFooterView(with: tableView)
            let viewBlock = footerConfiguration ?? { (footer, section) in footer.__fw_viewModel = nil }
            viewBlock(view, section)
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let heightBlock = heightForFooter {
            return heightBlock(section)
        }
        if let footerHeight = footerHeight {
            return footerHeight
        }
        
        let viewClass = viewForFooter?(section) ?? footerViewClass
        guard let footer = viewClass else { return 0 }
        
        if let view = footer as? UIView {
            return view.frame.size.height
        }
        if let clazz = footer as? UITableViewHeaderFooterView.Type {
            let viewBlock = footerConfiguration ?? { (footer, section) in footer.__fw_viewModel = nil }
            return tableView.fw.height(headerFooterViewClass: clazz, type: .footer, cacheBy: section) { (footerView) in
                viewBlock(footerView, section)
            }
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow?(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let title = titleForDelete?(indexPath) ?? deleteTitle
        return title != nil ? true : false
    }
    
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return titleForDelete?(indexPath) ?? deleteTitle
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let title = titleForDelete?(indexPath) ?? deleteTitle
        return title != nil ? .delete : .none
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            didDeleteRow?(indexPath)
        }
    }
}

extension Wrapper where Base: UITableView {
    public var delegate: TableViewDelegate {
        if let result = base.fw.property(forName: "fwDelegate") as? TableViewDelegate {
            return result
        } else {
            let result = TableViewDelegate()
            base.fw.setProperty(result, forName: "fwDelegate")
            base.dataSource = result
            base.delegate = result
            return result
        }
    }
    
    public static func tableView() -> Base {
        return tableView(.plain)
    }
    
    public static func tableView(_ style: UITableView.Style) -> Base {
        let tableView = Base(frame: .zero, style: style)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }
}

@objc extension UITableView {
    @objc(fw_delegate)
    public var __fw_delegate: TableViewDelegate {
        return fw.delegate
    }
    
    @objc(fw_tableView)
    public static func __fw_tableView() -> UITableView {
        return fw.tableView()
    }
    
    @objc(fw_tableView:)
    public static func __fw_tableView(_ style: UITableView.Style) -> UITableView {
        return fw.tableView(style)
    }
}

extension Wrapper where Base: UITableView {
    
    /// 是否启动高度估算布局，启用后需要子视图布局完整，无需实现heightForRow方法(iOS11默认启用，会先cellForRow再heightForRow)
    public var estimatedLayout: Bool {
        get { return base.__fw_estimatedLayout }
        set { base.__fw_estimatedLayout = newValue }
    }
    
    /// 清空Grouped样式默认多余边距，注意CGFLOAT_MIN才会生效，0不会生效
    public func resetGroupedStyle() {
        base.__fw_resetGroupedStyle()
    }

    /// 设置Plain样式sectionHeader和Footer跟随滚动(不悬停)，在scrollViewDidScroll:中调用即可(需先禁用内边距适应)
    public func follow(header: CGFloat, footer: CGFloat) {
        base.__fw_follow(withHeader: header, footer: footer)
    }

    /// reloadData完成回调
    public func reloadData(completion: (() -> Void)?) {
        base.__fw_reloadData(completion: completion)
    }

    /// reloadData清空尺寸缓存
    public func reloadDataWithoutCache() {
        base.__fw_reloadDataWithoutCache()
    }

    /// reloadData禁用动画
    public func reloadDataWithoutAnimation() {
        base.__fw_reloadDataWithoutAnimation()
    }

    /// reloadSections禁用动画
    public func reloadSectionsWithoutAnimation(_ sections: IndexSet) {
        base.__fw_reloadSectionsWithoutAnimation(sections)
    }

    /// reloadRows禁用动画
    public func reloadRowsWithoutAnimation(_ indexPaths: [IndexPath]) {
        base.__fw_reloadRowsWithoutAnimation(indexPaths)
    }

    /// 刷新高度等，不触发reload方式
    public func performUpdates(_ updates: (() -> Void)?) {
        base.__fw_performUpdates(updates)
    }
    
    /// 全局清空TableView默认多余边距
    public static func resetTableStyle() {
        Base.__fw_resetTableStyle()
    }
    
}

extension Wrapper where Base: UITableViewCell {
    
    /// 设置分割线内边距，iOS8+默认15.f，设为UIEdgeInsetsZero可去掉
    public var separatorInset: UIEdgeInsets {
        get { return base.__fw_separatorInset }
        set { base.__fw_separatorInset = newValue }
    }

    /// 获取当前所属tableView
    public weak var tableView: UITableView? {
        return base.__fw_tableView
    }

    /// 获取当前显示indexPath
    public var indexPath: IndexPath? {
        return base.__fw_indexPath
    }
    
    /// 延迟加载背景视图，处理section圆角、阴影等。会自动设置backgroundView
    public var backgroundView: TableViewCellBackgroundView {
        return base.__fw_backgroundView
    }
    
}
