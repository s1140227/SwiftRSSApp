//
//  NGWordManager.swift
//  SwiftRSSApp
//
//  Created by ユーエックスモバイル on 2015/02/27.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import Foundation

//ノーティフィケーション
struct NGWordManagerNotifi{
    static let NGWordListUpdate = "NGWordManagerNGWordListUpdateNotification"
}

//
let NGWordTypeAr = ["記事を非表示","ワードを非表示"]

//フィードクラス
class NGWord : Mappable{
    var word:String = ""
    var type:Int = 0
    
    required init(){}
    
    func mapping(map: Map) {
        word <= map["word"]
        type <= map["type"]
    }
}


class NGWordManager : NSObject{
    
    //NGワード一覧
    var ngAr = [NGWord]()
    
    
    //シングルトン
    class var instance : NGWordManager {
        struct Static {
            static let instance = NGWordManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        //保存されているNGワードリストの読み込み
        let ud = NSUserDefaults.standardUserDefaults()
        if let savedNGAr = ud.objectForKey("NGWordManagerNGAr") as? [[String:AnyObject]]{
            println(savedNGAr)
            ngAr = Mapper<NGWord>().mapArray(savedNGAr)
            
        }
    }
    
    
    //NGワード追加
    func addNGWord(ng:NGWord){
        if ng.word == "" {return}
        
        ngAr.append(ng)
        
        //save
        saveNGAr()
        
        //ニュースの表示を更新
        
    }
    
    
    //NGワード削除
    func removeNGWordAtIndex(index:Int){
        if ngAr.count <= index {return}
        
        ngAr.removeAtIndex(index)
        saveNGAr()
    }
    
    
    //ワードの保存
    private func saveNGAr(isNothingNotifi:Bool  = false){
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(Mapper().toJSONArray(ngAr), forKey: "NGWordManagerNGAr")
        ud.synchronize()
        
        if isNothingNotifi == false{
            
            //notifi
            NSNotificationCenter.defaultCenter().postNotificationName(NGWordManagerNotifi.NGWordListUpdate, object: nil ,userInfo:nil)
        }
        
        println("*****************")
        println(ud.objectForKey("NGWordManagerNGAr"))
        println("*****************")
        
    }
    
}


