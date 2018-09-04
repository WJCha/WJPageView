//
//  ViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/30.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

private let CELL = "ViewControllerCell"
class ViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataArr: [String] = ["标题样式案例", "标题栏和控制器组合使用", "XIB使用案例"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.title = "使用案例"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL)
        tableView.tableFooterView = UIView()
        
    }

}



extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL) else {
            return UITableViewCell(style: .value1, reuseIdentifier: CELL)
        }
        cell.textLabel?.text = dataArr[indexPath.row]
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(WJTitleBarStyleDemoController(), animated: true)
        } else if (indexPath.row == 1) {
            navigationController?.pushViewController(WJGroupUseViewController(), animated: true)
        } else {
            navigationController?.pushViewController(WJXibUseDemoViewController(), animated: true)
        }
    }
    
    
}











