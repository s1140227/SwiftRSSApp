//
//  RssNewsListVC.swift
//  rssApp
//
//  Created by ユーエックスモバイル on 2015/02/24.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import UIKit

class RssNewsListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    
    @IBOutlet weak var tbV: UITableView!
    let refreshC = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: NewsManagerNotifi.NewsListUpdate, object: nil)
        
        
        refreshC.addTarget(self, action:"refresh", forControlEvents:UIControlEvents.ValueChanged)
        tbV.addSubview(refreshC)
        
        if FeedManager.instance.feedAr.count == 0{
            self.performSegueWithIdentifier("pushFeedListVC", sender: self)
        }
    }
    
    func refresh(){
        NewsManager.instance.downloadAllFeed()
    }
    
    func reload(){
        
        ExUtil.dispatch_async_main {[weak self]() -> () in
            if let _self = self{
                _self.refreshC.endRefreshing()
                _self.tbV.reloadData()
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewsManager.instance.newsAr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("NewsCell") as! UITableViewCell
        
        let item =  NewsManager.instance.newsAr[indexPath.row]
        cell.textLabel?.text = "\(item.title)"
        cell.detailTextLabel?.text = "\(item.date.ExUtil_toDspString()) - \(item.source)"

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = NewsManager.instance.newsAr[indexPath.row]
        if item.link == nil{
            
            let url = item.title.componentsSeparatedByString(" http://")
            if url.count > 1{
                item.link = "http://" + url[1].componentsSeparatedByString(" ")[0]
            }
        }
        
        println(item.link)
        
        if let url = NSURL(string: item.link){
            UIApplication.sharedApplication().openURL(url)
        }

        
    }
}



