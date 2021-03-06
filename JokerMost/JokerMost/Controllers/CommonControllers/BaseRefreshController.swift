//
//  BaseRefreshController.swift
//  JokerMost
//
//  Created by ljy-335 on 14-10-9.
//  Copyright (c) 2014年 uni2uni. All rights reserved.
//

import Foundation
import UIKit

///
/// @brief 由HotController、LatestController、TruthController继承，用于
///        统一管理数据显示
/// @data   2014-10-09
/// @author huangyibiao
class BaseRefreshController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    RefreshViewDelegate,
    JokerCellDelegate {
    var refreshView: RefreshView?
    var dataSource = NSMutableArray()
    var tableView: UITableView?
    var currentPage: Int = 1
    var cellIdentifier = "JokerCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false;
        self.view.backgroundColor = UIColor.whiteColor()
        // table view
        self.tableView = UITableView(frame: CGRectMake(0, 64, self.view.width(), kScreenHeight - 49 - 64))
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.tableView!)
        var nib = UINib(nibName: "JokerCell", bundle: nil)
        self.tableView!.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        
        // refresh view
        var array = NSBundle.mainBundle().loadNibNamed("RefreshView", owner: self, options: nil) as Array
        self.refreshView = array[0] as? RefreshView
        self.tableView!.tableFooterView = self.refreshView
        self.refreshView!.delegate = self
    }
    
    ///
    /// @brief 加载更多数据，此方法由子类调用
    /// @param urlString 请求地址，其中不指定page值
    func downloadData(#urlString: String) {
        let url = "\(urlString)\(self.currentPage)"
        
        self.refreshView!.startLoadingMore()
        
        HttpRequest.request(urlString: url) { (data) -> Void in
            if data == nil {
                UIAlertView.show(title: "温馨提示", message: "加载失败!")
            } else {
                var itemArray = data?["items"] as NSArray
                
                for item: AnyObject in itemArray {
                    self.dataSource.addObject(item)
                }
                
                self.tableView!.reloadData()
                self.refreshView!.stopLoadingMore()
                self.currentPage++
            }
        }
    }
    
    ///
    /// UITableViewDataSource
    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as? JokerCell
        
        cell?.delegate = self
        
        if indexPath.row < self.dataSource.count {
            var dataDict = self.dataSource[indexPath.row] as NSDictionary
            cell?.data = dataDict
        }
        
        return cell!
    }
    
    ///
    /// UITableViewDelegate
    ///
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var index = indexPath.row
        var data = self.dataSource[index] as NSDictionary
        
        return  JokerCell.cellHeight(data)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index = indexPath.row
        var data = self.dataSource[index] as NSDictionary
        
        let comment = CommentController()
        comment.jokeId = data["id"] as? String
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    ///
    /// JokerCellDelegate 代理方法实现
    ///
    func jokerCell(cell: JokerCell, didClickPicture picutre: String) {
        let browser = PhotoBrowserController()
        browser.bigImageUrlString = picutre
        self.navigationController?.pushViewController(browser, animated: true)
    }
}