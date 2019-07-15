//
//  ChatRoomViewController.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController {

    public lazy var cellModels = [ChatRoomBaseCellModel]()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        let view = UIView()
        view.backgroundColor = UIColor.gray
        tableView.backgroundView = view
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        self.getData()
        self.tableView.reloadData()
    }
    
    fileprivate func getData() {
        for i in 0...10 {
            let sendId: Int64 = i % 2 == 0 ? AuthenticationManager.shared.loginUser!.id : Int64(0)
            if i < 6 {
                let textModel = ChatRoomModel(text: "今天我好开心啊，我在家啊，今天休息了，😝😸我的电话是18810181988，，我的网站：https://objc.com，ajdhakjdhajsdhakjdhakjdhkghghghkghgjkgjkgsfsdfsdfsfdsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfs", sendId: sendId, receiveId: Int64(i))
                let cellModel = ChatRoomBaseCellModel(model: textModel, cellId: "textcell")
                self.cellModels.append(cellModel)
            }
            else if i < 8 {
                let dict: [String : Any] = ["original_url": "http://pic1.win4000.com/wallpaper/c/53cdd1f7c1f21.jpg", "thumb_url": "http://pic1.win4000.com/wallpaper/c/53cdd1f7c1f21.jpg", "width": CGFloat(1920.0), "height": CGFloat(1080.0), "image_id": Int64(i)]
                
                let imageModel = ChatRoomModel(imageModel: ChatImageModel(dict: dict), sendId: sendId, receiveId: Int64(i))
                let cellModel = ChatRoomBaseCellModel(model: imageModel, cellId: "imagecell")
                self.cellModels.append(cellModel)
            }
            else {
                let dict: [String : Any] = ["original_url": "http://www.16fafa.cn/file/upload/201610/13/172239841.jpg", "thumb_url": "http://www.16fafa.cn/file/upload/201610/13/172239841.jpg", "width": CGFloat(442.0), "height": CGFloat(442.0), "image_id": Int64(i)]
                
                let imageModel = ChatRoomModel(imageModel: ChatImageModel(dict: dict), sendId: sendId, receiveId: Int64(i))
                let cellModel = ChatRoomBaseCellModel(model: imageModel, cellId: "imagecell")
                self.cellModels.append(cellModel)
            }
        }
    }
    
    
    fileprivate func setupUI() {
        view.addSubview(self.tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = self.cellModels[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellId)
        if cell == nil {
            switch cellModel.model!.messageContentType {
            case .Text :
                cell  = ChatRoomTextTableViewCell(style: .default, reuseIdentifier: cellModel.cellId)
                
            case .Image :
                cell  = ChatRoomImageTableViewCell(style: .default, reuseIdentifier: cellModel.cellId)
                
            case .Voice:
                cell  = ChatRoomVoiceTableViewCell(style: .default, reuseIdentifier: cellModel.cellId)
                
            case .System:
                cell  = ChatRoomAdminTableViewCell(style: .default, reuseIdentifier: cellModel.cellId)
                
            case .File:
                cell  = ChatRoomFileTableViewCell(style: .default, reuseIdentifier: cellModel.cellId)
                
            case .Time :
               cell  = ChatRoomDateTimeTableViewCell(style: .default, reuseIdentifier: cellModel.cellId)
            }
            
        }
        
        if let c = cell as? ChatRoomBaseTableViewCell {
            c.cellModel = cellModel
            return c
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
