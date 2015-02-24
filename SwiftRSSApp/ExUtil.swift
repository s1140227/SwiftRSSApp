//
//  ExUtil.swift
//  rssApp
//
//  Created by ユーエックスモバイル on 2015/02/24.
//  Copyright (c) 2015年 ux-mobile. All rights reserved.
//

import Foundation
import UIKit

class ExUtil{
    
    class func getVC()->UIViewController{
        
        let vc:UIViewController? = UIApplication.sharedApplication().windows[0].rootViewController
        
        if let nvc = vc as? UINavigationController{
            return nvc.visibleViewController
        }
        
        return vc!
    }
    
    class func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    class func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    class func dispatch_async_after_global(delay:Double , block: () -> ()){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    class func dispatch_async_after_main(delay:Double , block: () -> ()){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
    }
    
    private struct __network {
        static var hud:MBProgressHUD!
    }
    
    class func progressShow(){
        ExUtil.progressDismiss()
        ExUtil.dispatch_async_main { () -> () in
            ExUtil.__network.hud = MBProgressHUD.showHUDAddedTo(ExUtil.getVC().view, animated: true)
        }
    }
    
    class func progressDismiss(){
        ExUtil.dispatch_async_main { () -> () in
            if ExUtil.__network.hud != nil{
                ExUtil.__network.hud.hide(true)
            }
        }
    }
    

    
}

extension NSDate{
    
    func ExUtil_toDspString() -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd(EEE)"
        return dateFormatter.stringFromDate(self)
    }
}