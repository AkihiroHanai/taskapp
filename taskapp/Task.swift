//
//  Task.swift
//  taskapp
//
//  Created by 花井章宏 on 2016/06/29.
//  Copyright © 2016年 akihiro.hanai. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    // カテゴリー
    dynamic var category = "" // 課題用の追記
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
