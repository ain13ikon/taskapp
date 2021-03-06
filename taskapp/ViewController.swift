//
//  ViewController.swift
//  taskapp
//
//  Created by きたむら on 2018/09/06.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var categoryArray: [String] = []
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付が近い順でソート：降順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        categoryPicker.delegate = self
        
        updateCategory()
        
        //        searchBar.isHidden = true
        
        print("デバッグ：　デバッグの表示確認")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            print("デバッグ：　セルのタップから移動します")
            let indexPath = self.tableView.indexPathForSelectedRow
            //メモ：遷移先に情報を渡している
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            print("デバッグ：　＋から移動します")
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            //メモ：遷移先に情報を渡している
            inputViewController.task = task
        }
    }
    
    //UIPickerのプロトコル
    //表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //表示するアイテムの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return categoryArray[row]
    }
    
    //カテゴリー検索
    //pickerViewが操作された時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        print("デバッグ： \(self.categoryPicker.selectedRow(inComponent: 0))")
        let searchNumber = self.categoryPicker.selectedRow(inComponent: 0)
        //print("デバッグ：　\(searchCategory)")
        //検索
        if searchNumber == 0 {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        }else{
            taskArray = try! Realm().objects(Task.self).filter("categoryId == %@", searchNumber).sorted(byKeyPath: "date", ascending: false)
            
        }
        
        //完全一致は"category == %@"
        
        //検索をかけてリロード
        tableView.reloadData()
    }
    
    //カテゴリーの更新
    func updateCategory(){
        print("カテゴリーの更新")
        //print(categoryArray)
        categoryArray = ["ALL"]
        print(categoryArray)
        let categoryDataAll = realm.objects(Category.self)
        print(categoryDataAll)
        //var categoryArray_: [String] = []
        for item in categoryDataAll {
            print("デバッグ：　\(item.name)")
            self.categoryArray.append(String(item.name))
        }
        print(categoryArray)
    }
    //UITableViewDataSourceのプロトコルメソッドを記述
    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    
    //セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        //CellはパーツのCellのプロパティで自分で設定した値
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        //カテゴリーの表示
        //let category = task.category
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: task.date)
        var category = ""
        if task.categoryId == 0 {
            category = ""
            print("未選択です")
        }else{
            category = realm.objects(Category.self)[task.categoryId - 1].name
            print("選択されています")
        }
        print(category)
        cell.detailTextLabel?.text = dateString + "    カテゴリー：\(category)"
        
        return cell
    }
    
    //UITableViewDelegateのプロトコルメソッド
    //セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("デバッグ：　セルがタップされました")
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
            
        }
    }
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCategory()
        categoryPicker.reloadAllComponents()
        tableView.reloadData()
    }
    
    //searchBarの設定
    /*  メモ：サーチバーは使っていない
     //テキスト変更時に呼ばれる
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     //検索する
     //searchItems(searchText: searchText)
     print("デバッグ：サーチテキストが変更されました")
     print("デバッグ：　\(searchText)")
     //searchCategory(searchText: searchText)
     
     //検索
     /*
     if searchText == "" {
     taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
     }else{
     taskArray = try! Realm().objects(Task.self).filter("category == %@", searchText).sorted(byKeyPath: "date", ascending: false)
     
     }
     */
     
     //完全一致は"category == %@"
     
     //検索をかけてリロード
     tableView.reloadData()
     
     }
     */
    
    
}

