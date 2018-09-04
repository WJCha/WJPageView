//
//  WJMusicViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit
private let CELLID = "WJMusicViewControllerCell"
class WJMusicViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELLID)
        return tableView
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}


extension WJMusicViewController: WJPageReloadable {
    func titleBarViewTitleDidRepeatClicked() {
        print("音乐标题重复点击")
    }
}

extension WJMusicViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CELLID) else {
            return UITableViewCell(style: .value1, reuseIdentifier: CELLID)
        }
        cell.textLabel?.text = "第\(indexPath.row)行"
        return cell
    }
    
}

extension WJMusicViewController: UITableViewDelegate {
    
}
