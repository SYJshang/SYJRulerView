//
//  ViewController.swift
//  RulerKit
//
//  Created by 1334858022@qq.com on 12/29/2020.
//  Copyright (c) 2020 1334858022@qq.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cell";
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellID)
        if indexPath.row == 0 {
            cell.textLabel?.text = "刻度尺 --- 直尺"
        } else {
            cell.textLabel?.text = "刻度尺 --- 圆尺"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(StraightRulerViewController(), animated: true)
        } else {
            self.navigationController?.pushViewController(RoundRulerViewController(), animated: true)
        }
        
    }
    
}

