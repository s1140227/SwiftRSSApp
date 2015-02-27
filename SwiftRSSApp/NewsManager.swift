//
//  NewsManager.swift
//  rssApp
//
//  Created by ユーエックスモバイル on 2015/02/24.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import Foundation

//ノーティフィケーション
struct NewsManagerNotifi{
    static let NewsListUpdate = "DataManagerNewsListUpdateNotification"
}


//ニュースクラスにソースプロパティを追加

private var sourceAssociationKey: UInt8 = 99

extension MWFeedItem{
    
    var source:String!{
        get {
            return objc_getAssociatedObject(self, &sourceAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &sourceAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}


class NewsManager:NSObject,MWFeedParserDelegate{
    
    //RSSから取得したニュースの配列
    var newsAr = [MWFeedItem]()
    private var tmpNewsAr = [MWFeedItem]()
    
    //ローディングカウンター
    var downloadFinishCounter = 0
    
    
    
    //シングルトン
    class var instance : NewsManager {
        struct Static {
            static let instance = NewsManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ngWordUpdate", name: NGWordManagerNotifi.NGWordListUpdate, object: nil)
        
    }
    
    
    //全フィードを更新
    func downloadAllFeed(){
        
        ExUtil.progressShow()
        
        tmpNewsAr = [MWFeedItem]()
        downloadFinishCounter = 0
        
        for(var i = 0; i < FeedManager.instance.feedAr.count; i++){
            
            var _i = i
            ExUtil.dispatch_async_after_global(0.1, block: {() -> () in
                NewsManager.instance.downloadAtFeedIndex(_i)
            })
            
        }
        
    }
    
    //各フィードのニュースをダウンロード
    func  downloadAtFeedIndex(index:Int){
        if FeedManager.instance.feedAr.count <= index {return}
        
        println(index)
        
        let feed = FeedManager.instance.feedAr[index]
        feed.parser = MWFeedParser(feedURL: feed.url)
        feed.parser.delegate = self
        feed.parser.parse()
        
    }
    
    //ダウンロードキュー
    private func incDownloadCounter(){
        //ローディングの削除
        downloadFinishCounter += 1
        if FeedManager.instance.feedAr.count - 1 <= downloadFinishCounter{
            ExUtil.progressDismiss()
        }
    }
    
    
    func feedParserDidStart(parser: MWFeedParser!) {
        println("feedParserDidStart")
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        incDownloadCounter()
        
        //sort
        tmpNewsAr.sort { (cat1, cat2) -> Bool in
            let cmp = cat1.date.compare(cat2.date)
            if cmp == NSComparisonResult.OrderedDescending {return true}
            return false
        }
        
        //NGワードを削除しつつ表示用配列にマッピング
        ngWordRemove()
        
        
        //notifi
        NSNotificationCenter.defaultCenter().postNotificationName(NewsManagerNotifi.NewsListUpdate, object: nil ,userInfo:nil)
        
        println("feedParserDidFinish")
    }
    
    
    //通信エラー //各フィードのタイトル更新
    func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
        incDownloadCounter()
        
        println(error)
        
        var title = ""

        switch error.code{
        case 1:
            title = "【エラー】内部処理エラー"
        case 2:
            title = "【エラー】通信エラー"
        case 3:
            title = "【エラー】解析エラー"
        case 4:
            title = "【エラー】ソース元の形式不具合"
        default :
            title = error.description
            
        }
        
        FeedManager.instance.updateTitleAtParser(parser, title: title)
        
    }
    
    //各フィードのタイトル更新
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        println(info.title)
        FeedManager.instance.updateTitleAtParser(parser, title: info.title)
    }
    
    //各ニュースアイテム保存
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        item.source = FeedManager.instance.getTitleAtParser(parser)
        tmpNewsAr.append(item)
        
    }

    
    
    
    //NGワードチェック
    
    func ngWordUpdate(){
        
        //NGワードを削除しつつ表示用配列にマッピング
        ngWordRemove()
        
        //notifi
        NSNotificationCenter.defaultCenter().postNotificationName(NewsManagerNotifi.NewsListUpdate, object: nil ,userInfo:nil)
        
    }
    
    func ngWordRemove(){
        
        newsAr = [MWFeedItem]()
        
        for news in tmpNewsAr{
            if !isNG(news){ newsAr.append(news)}
        }
    }
    
    func isNG(news:MWFeedItem) -> Bool{
        
        for ng in NGWordManager.instance.ngAr{
            
            let range = (news.title as NSString).rangeOfString(ng.word)
            if range.location != NSNotFound{
                
                //記事を削除するケース
                if ng.type == 0{
                    println(">>>削除対象>>>>>\(news.title)")
                    return true
                }
                
                //文字を削除するケース
                if ng.type == 1{
                    
                    news.title = (news.title as NSString).stringByReplacingOccurrencesOfString(ng.word, withString: "***")
                    
                }
                
            }
            
        }
        
        return false
    }
    
}




