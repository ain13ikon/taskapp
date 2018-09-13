//
//  InputViewController.swift
//  taskapp
//
//  Created by きたむら on 2018/09/07.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    //    var categoryData_ = ["食事", "書籍", "衣類", "交通費","その他"]
    var categoryArray: [String] = []
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    //    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var task: Task!
    //var category: Category!
    let realm = try! Realm()
    
    
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        print("デバッグ： \(self.categoryPicker.selectedRow(inComponent: 0))")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        //背景をタップしたらdismissKeyboardメソッドを呼ぶようにする
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        updateCategory()
        
        //入力済みのデータを表示
        //メモ：taskの中身は遷移時に渡されている
        //categoryTextField.text = task.category
        categoryPicker.selectRow(task.categoryId, inComponent: 0, animated: true)
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        
    }
    
    func updateCategory(){
        print("カテゴリーの更新")
        //print(categoryArray)
        categoryArray = ["(未選択)"]
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
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //画面が消える時
    //データをRealmに保存する
    override func viewWillDisappear(_ animated: Bool){
        try! realm.write {
            //            self.task.category = self.categoryTextField.text!
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            let category: Int? = self.categoryPicker.selectedRow(inComponent: 0)
            print("デバッグ：　")
            print(category)
            
            if category == Optional(0){
                print("カテゴリーが選ばれていません")
            }else{
                print("カテゴリーを登録します222")
                //self.task.categoryId = self.categoryPicker.selectedRow(inComponent: 0)
            }
            self.task.categoryId = self.categoryPicker.selectedRow(inComponent: 0)
            self.realm.add(self.task, update: true)
            print("ok")
        }
        
        setNotification(task_t: task)
        
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task_t: Task){
        let content = UNMutableNotificationContent()
        
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("再読み込み")
        updateCategory()
        categoryPicker.reloadAllComponents()
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
