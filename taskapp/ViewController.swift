//
//  ViewController.swift
//  taskapp
//
//  Created by 花井章宏 on 2016/06/29.
//  Copyright © 2016年 akihiro.hanai. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    // TableView - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // 検索窓
    var searchController = UISearchController(searchResultsController: nil)
    
    //検索結果配列
    var searchResults = [String]()
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト - 日付近い順\順でソート：降順 - 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: true)
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 結果表示用のビューコントローラーに自分を設定する。
        searchController.searchResultsUpdater = self
        
        // 検索中にコンテンツをグレー表示にしない。
        searchController.dimsBackgroundDuringPresentation = false
        
        // テーブルビューのヘッダーにサーチバーを設定する。
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // segue で画面遷移するに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        // セルがタップされた場合の処理
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        
        // Addボタンがタップされた場合の処理
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    // ▶︎▶︎▶︎▶︎▶︎▶︎▶︎▶︎▶︎▶︎ ここから UItableViewDataSourceProtocol - method ▶︎▶︎▶︎▶︎▶︎▶︎▶︎▶︎▶︎▶︎
    
    
    
    // データの数 - セルの数を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // DB内のタスクの数
        return taskArray.count
    }
    
    
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    
    // 各セルを選択した時に実行されるメソッド - セルをタップした時にタスク入力画面に遷移させる
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("cellSegue",sender: nil) // ←追加する
    }
    
    
    
    // 検索文字列変更時の呼び出しメソッド
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // 検索に使う文字列
        let searchText = searchController.searchBar.text!
        
        if searchText.isEmpty {
            
            // 検索文字列が空の場合、全てのタスクを並び替えて使う
            taskArray = realm.objects(Task).sorted("date", ascending: true)
            
        } else {
            
            // 検索文字列で検索＆並べ替え
            taskArray = realm.objects(Task).filter("category = '\(searchText)'").sorted("date", ascending: true)
        }
        
        // 表示を更新
        tableView.reloadData()
    }
    
    
    
    // セルが削除が可能なことを伝えるメソッド
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        // taskappでは削除を可能にするから下の記述を行う
        return UITableViewCellEditingStyle.Delete
    }
    
    
    
    // Delete ボタンが押された時に呼ばれるメソッド - Deleteボタンが押されたときにローカル通知をキャンセルし、データベースからタスクを削除する
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除する  // ← 以降追加する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    
    
    // ◀︎◀︎◀︎◀︎◀︎◀︎◀︎◀︎◀︎◀︎ ここまで UItableViewDataSourceProtocol - method ◀︎◀︎◀︎◀︎◀︎◀︎◀︎◀︎◀︎◀︎
    
    
    
}