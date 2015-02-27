//
//  NGListVC.swift
//  rssApp
//
//  Created by ユーエックスモバイル on 2015/02/27.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import Foundation


class NGListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate{
    
    
    @IBOutlet weak var tbV: UITableView!
    
    var additionalWord:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: NGWordManagerNotifi.NGWordListUpdate, object: nil)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload(){
        ExUtil.dispatch_async_main {[weak self]() -> () in
            if let _self = self{ _self.tbV.reloadData() }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NGWordManager.instance.ngAr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("NGWordCell") as UITableViewCell
        
        let item =  NGWordManager.instance.ngAr[indexPath.row]
        cell.textLabel?.text = item.word
        cell.detailTextLabel?.text = NGWordTypeAr[item.type]
        
        return cell
    }
    
    
    //削除
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        NGWordManager.instance.removeNGWordAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Left)
        
    }
    
    
    //NGワードの追加
    
    @IBAction func pressAddBtn(sender: UIBarButtonItem) {
        showInputAlert()
    }
    
    func showInputAlert(){
        let alert = UIAlertView(title: "NGワードの追加", message: "対象の文字を入力してください。", delegate: self, cancelButtonTitle: "キャンセル", otherButtonTitles:"追加")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.tag = 1
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 && buttonIndex == 1{
            if let word = alertView.textFieldAtIndex(0)?.text as String?{
                additionalWord = word
                println(additionalWord)
                
                
                let picker = ActionSheetStringPicker(title: "処理選択", rows: NGWordTypeAr, initialSelection: 0, doneBlock: { [weak self](picker, index, data) -> Void in
                    
                    if let _self = self{
                        let addNG = NGWord()
                        addNG.word = _self.additionalWord
                        addNG.type = index
                        
                        NGWordManager.instance.addNGWord(addNG)
                    }
                    
                }, cancelBlock: { (picker) -> Void in
                }, origin: self.view)
                
                picker.showActionSheetPicker()
                
            }
        }
    }
}