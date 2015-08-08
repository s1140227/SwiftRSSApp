//
//  FeedListVC.swift
//  rssApp
//
//  Created by ユーエックスモバイル on 2015/02/24.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import Foundation


class FeedListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate{
    
    
    @IBOutlet weak var tbV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: FeedManagerNotifi.FeedListUpdate, object: nil)
        
        if FeedManager.instance.feedAr.count == 0{
            showInputAlert()
        }
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
        return FeedManager.instance.feedAr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as! UITableViewCell
        
        let item =  FeedManager.instance.feedAr[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.url?.absoluteString
        
        return cell
    }
    
    
    //削除
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        FeedManager.instance.removeFeedAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Left)
        
    }
    
    
    //フィードの追加
    
    @IBAction func pressAddBtn(sender: UIBarButtonItem) {
        showInputAlert()
    }
    
    func showInputAlert(){
        let alert = UIAlertView(title: "RSSフィードの追加", message: "URLを入力してください。", delegate: self, cancelButtonTitle: "キャンセル", otherButtonTitles:"追加")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.tag = 1
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 && buttonIndex == 1{
            if let url = alertView.textFieldAtIndex(0)?.text as String?{
                println(url)
                FeedManager.instance.addFeedURL(url)
            }
        }
    }
}