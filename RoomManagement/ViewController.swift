//
//  ViewController.swift
//  RoomManagement
//
//  Created by KessaPassa on 2018/07/26.
//  Copyright © 2018 KessaPassa. All rights reserved.
//

import UIKit
import UserNotifications

protocol UpdateDelegate {
    func updateMember(_ inRoom: [String]?, _ goBack: [String]?)
}

enum TableTags: Int {
    case inRoom = 0
    case goBack = 1
}

class ViewController: UIViewController {
    
    let server = ServerProcess()
    
    
    @IBOutlet weak var inRoomTableView: UITableView!
    @IBOutlet weak var goBackTableView: UITableView!
    
    let MEMBER_COUNT = 7
    let cellId = "cell"
    
    var inRoomList: [String] = []//["染谷一輝", "古川義人", "原圭範"]
    var goBackList: [String] = []//["林敏生", "土屋克典", "大場大輔", "酒井寛崇"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inRoomTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        goBackTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        inRoomTableView.tag = TableTags.inRoom.rawValue
        goBackTableView.tag = TableTags.goBack.rawValue
        
        inRoomTableView.sectionIndexMinimumDisplayRowCount = MEMBER_COUNT
        goBackTableView.sectionIndexMinimumDisplayRowCount = MEMBER_COUNT
        
        inRoomTableView.dataSource = self
        goBackTableView.dataSource = self
        
        inRoomTableView.delegate = self
        goBackTableView.delegate = self
        
        self.server.updateDelegate = self
        self.server.getInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func alertInRoom(_ name: String, _ enter: String, _ cancel: String){
        let alert: UIAlertController = UIAlertController(title: name, message: nil, preferredStyle: .alert)
        let actionOne = UIAlertAction.init(title: enter, style: .default){ _ in
            self.server.sendInfo(name, .enter)
        }
        let actionTwo = UIAlertAction.init(title: cancel, style: .cancel)
        
        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        present(alert, animated: true, completion: nil)
    }
    
    func alertGoBack(_ name: String, _ around: String, _ back:String, _ cancel:String){
        let alert: UIAlertController = UIAlertController(title: name, message: nil, preferredStyle: .alert)
//        let actionOne = UIAlertAction.init(title: around, style: .default){ _ in
//            self.server.sendInfo(name, .goaround)
//        }
        let actionTwo = UIAlertAction.init(title: back, style: .default){ _ in
            self.server.sendInfo(name, .goback)
        }
        let actionThree = UIAlertAction.init(title: cancel, style: .cancel)
        
//        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        alert.addAction(actionThree)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func membersListUpdate(_ sender: UIButton) {
        self.server.getInfo()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == TableTags.inRoom.rawValue {
            return inRoomList.count
        }
        else if tableView.tag == TableTags.goBack.rawValue{
            return goBackList.count
        }
        else{
            return -1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath as IndexPath)
        
        if tableView.tag == TableTags.inRoom.rawValue {
            cell.textLabel!.text = "\(inRoomList[indexPath.row])"
        }
        else if tableView.tag == TableTags.goBack.rawValue{
            cell.textLabel!.text = "\(goBackList[indexPath.row])"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == TableTags.inRoom.rawValue {
            alertGoBack(inRoomList[indexPath.row], "一時退出", "退勤", "キャンセル ")
        }
        else if tableView.tag == TableTags.goBack.rawValue{
            alertInRoom(goBackList[indexPath.row], "出勤", "キャンセル")
        }
    }
}

extension ViewController: UpdateDelegate{
    func updateMember(_ inRoom: [String]?, _ goBack: [String]?) {
        print(inRoom!)
        print(goBack!)
        
        // 初期化
        inRoomList = []
        goBackList = []
        
        // 新しいメンバーに入れ替え
        if inRoom != nil{
            inRoomList.append(contentsOf: inRoom as! [String])
        }
        
        if goBack != nil {
            goBackList.append(contentsOf: goBack as! [String])
        }
        
//        print(inRoomList)
//        print(goBackList)
        
        // 描画の更新
        DispatchQueue.main.async{
            self.inRoomTableView.reloadData()
            self.goBackTableView.reloadData()
        }
    }
}


