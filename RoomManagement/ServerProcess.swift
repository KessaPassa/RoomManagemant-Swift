//
//  ContactServer.swift
//  RoomManagement
//
//  Created by KessaPassa on 2018/07/27.
//  Copyright © 2018 KessaPassa. All rights reserved.
//

import Foundation

let serverURL = "https://slackbot-extensions-master.herokuapp.com"
//let serverURL = "http://10.20.78.110:8010"

enum SendStatus: Int {
    case enter
    case goback
    case goaround
}

class ServerProcess {
    
    var updateDelegate: UpdateDelegate!
    
    // メンバー情報を取得する
    func getInfo() {
        var request = URLRequest(url: URL(string: "\(serverURL)/room/info")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                print("error: \(error!)")
                return
            }
//            let output = String(data: data!, encoding: .utf8)!
//            print("output: \(output)")
            
            do {
                // dataをJSONパースし、変数"getJson"に格納
                let json = try JSONSerialization.jsonObject(
                    with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                let inRoom = json["in"] as? [String]
                let goBack = json["out"] as? [String]

                self.updateDelegate.updateMember(inRoom, goBack)

            } catch {
                print ("json error")
                return
            }
        })
        task.resume()
    }
    
    
    // 入退室を送信する
    func sendInfo(_ name:String, _ status: SendStatus) {
        let name = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let status = status.rawValue
        let params = "name=\(name)&status=\(status)"
        
        var request = URLRequest(url: URL(string: "\(serverURL)/room/management?\(params)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        print("0")
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                print("error: \(error!)")
                return
            }
//            let output = String(data: data!, encoding: .utf8)!
//            print("output: \(output)")
            
            // すぐにgetInfoするとデータベースへ書き込みする前に取得してしまうので、少し待つ
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 再度描画するため
                self.getInfo()
            }
        })
        task.resume()
    }
}
