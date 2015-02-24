//
//  FeedManager.swift
//  rssApp
//
//  Created by ユーエックスモバイル on 2015/02/24.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import Foundation

//ノーティフィケーション
struct FeedManagerNotifi{
    static let FeedListUpdate = "FeedManagerFeedListUpdateNotification"
}


//フィードクラス
class Feed : Mappable{
    var title:String = ""
    var url:NSURL?
    var parser:MWFeedParser!
    
    required init(){}
    
    func mapping(map: Map) {
        title <= map["title"]
        if title == "" {title = "タイトル未取得"}
        url <= (map["url"],URLTransform())
    }
}



class FeedManager : NSObject{
    
    //フィード一覧
    var feedAr = [Feed]()
    
    
    //シングルトン
    class var instance : FeedManager {
        struct Static {
            static let instance = FeedManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        //保存されているフィードリストの読み込み
        let ud = NSUserDefaults.standardUserDefaults()
        if let savedFeedAr = ud.objectForKey("FeedManagerFeedAr") as? [[String:AnyObject]]{
            println(savedFeedAr)
            feedAr = Mapper<Feed>().mapArray(savedFeedAr)
            
            //ニュース取得
            ExUtil.dispatch_async_global({ () -> () in
                NewsManager.instance.downloadAllFeed()
            })
        }
    }
    
    //フィード追加
    func addFeedURL(url:String){
        if url == "" {return}
        
        let feed = Feed()
        feed.url = NSURL(string: url)
        feedAr.append(feed)
        
        //save
        saveFeedAr()
        
        //ニュースを追加ダウンロード
        var _i = feedAr.count - 1
        ExUtil.dispatch_async_after_global(0.1, block: { () -> () in
            NewsManager.instance.downloadAtFeedIndex(_i)
        })
    }
    
    //フィード削除
    func removeFeedAtIndex(index:Int){
        if feedAr.count <= index {return}
        
        feedAr.removeAtIndex(index)
        saveFeedAr(isNothingNotifi: true)
        
    }

    
    //各フィードのタイトル変更
    func updateTitleAtParser(parser: MWFeedParser!,title:String){
        for feed in feedAr{
            if feed.parser != nil && feed.parser == parser{
                feed.title = title
                //保存
                saveFeedAr()
                break
            }
        }
    }

    //各フィードのタイトル取得
    func getTitleAtParser(parser: MWFeedParser!) -> String{
        for feed in feedAr{
            if feed.parser != nil && feed.parser == parser{
                return feed.title
            }
        }
        return ""
    }


    //フィードの保存
    private func saveFeedAr(isNothingNotifi:Bool  = false){
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(Mapper().toJSONArray(feedAr), forKey: "FeedManagerFeedAr")
        ud.synchronize()
        
        if isNothingNotifi == false{
        
            //notifi
            NSNotificationCenter.defaultCenter().postNotificationName(FeedManagerNotifi.FeedListUpdate, object: nil ,userInfo:nil)
        }
        
        println("*****************")
        println(ud.objectForKey("FeedManagerFeedAr"))
        println("*****************")
        
    }
}




