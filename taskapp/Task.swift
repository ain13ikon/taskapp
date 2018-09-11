//
//  Task.swift
//  taskapp
//
//  Created by きたむら on 2018/09/07.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

//import Foundation 不要

import RealmSwift

class Task: Object {
    //管理用ID。　プライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //カテゴリー
    @objc dynamic var category: String = ""
    
    /**
        idをプライマリーキーとして設定
    */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
