//
//  AddCategoryController.swift
//  taskapp
//
//  Created by きたむら on 2018/09/12.
//  Copyright © 2018年 ain13ikon. All rights reserved.
//

import UIKit
import RealmSwift

class AddCategoryController: UIViewController {
    
    let realm = try! Realm()
    let category = Category()

    @IBOutlet weak var categoryField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool){
        
        if categoryField.text! == ""{
            print("デバッグ：　空欄のため、登録しません")
            return
        }
        let allTasks = realm.objects(Category.self)

        //カテゴリーが被っていなかったら
        if allTasks.filter("name == %@", categoryField.text!).count == 0 {
            
            if allTasks.count != 0 {
                self.category.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            try! realm.write {
                self.category.name = self.categoryField.text!
                self.realm.add(self.category, update: true)
            }
            print("カテゴリーを新規登録しました")
        }else{
            print("カテゴリーが重複しています")
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("戻ります")
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
