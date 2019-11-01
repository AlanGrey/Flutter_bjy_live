import Flutter
import UIKit

import BJLiveUI
import BJPlaybackUI


public class SwiftFlutterLivePlugin: NSObject, FlutterPlugin ,BJVRequestTokenDelegate{
    
    
    

    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_live", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterLivePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    
    
    
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if(call.method == "startLive"){
        
        let dic =  call.arguments as! Dictionary<String,Any>
        
        //开启直播
        let name = dic["userName"] as! String
        let num = dic["userNum"] as! String
        let avatar = dic["userAvatar"] as! String
        let sign = dic["sign"] as! String
        let roomId = dic["roomId"] as! String
        
        startLive(name: name, num: num, avatar: avatar, sign: sign, roomId: roomId)
        
        result(true)
    }
    if(call.method == "startBack"){
        
        let dic =  call.arguments as! Dictionary<String,Any>
        
        //开启回放
        let roomId = dic["roomId"] as! String
        let token = dic["token"] as! String
        let sessionId = dic["sessionId"] as! String
       
        
        startBack(roomId: roomId, token: token, sessionId: sessionId)
        
        result(true)
    }
    
    if(call.method == "startVideo"){
        
        let dic =  call.arguments as! Dictionary<String,Any>
        
        //开启点播
        let videoId = dic["videoId"] as! String
        let token = dic["token"] as! String
        let userName = dic["userName"] as! String
        let userId = dic["userId"] as! String
        let title = dic["title"] as! String
       
        
        startVideo(videoId: videoId, token: token, userName: userName,userId:userId,title:title,result: result)
        
        
    }
    
    
    
  }
    
    
    public func startLive(name:String,num:String,avatar:String,sign:String,roomId:String){
        
        
        let bjuser = BJLUser.init(number: num, name: name, groupID: 0, avatar: avatar, role: BJLUserRole.student)
        
        
        let bjlrc = BJLRoomViewController.instance(withID: roomId, apiSign: sign, user: bjuser) as! BJLRoomViewController
        
    
        
        let vc = UIApplication.shared.keyWindow?.rootViewController
        
        
        vc?.present(bjlrc, animated: true, completion: nil)
    }
    
    
    public func startBack(roomId:String,token:String , sessionId:String){
        

        BJVideoPlayerCore.tokenDelegate = self
        
        let bjpvc = BJPRoomViewController.onlinePlaybackRoom(withClassID: roomId, sessionID: sessionId, token: token) as! BJPRoomViewController
        
        let vc = UIApplication.shared.keyWindow?.rootViewController
        
        vc?.present(bjpvc, animated: true, completion: nil)
        
        
        
        
    }
   
    
    
    public func startVideo(videoId:String,token:String , userName:String,userId:String,title:String,result: @escaping FlutterResult){
           

           BJVideoPlayerCore.tokenDelegate = self
          
            let bjpvc = BJYDBViewController.init()
            bjpvc.token = token
            bjpvc.videoId = videoId
            bjpvc.bjtitle = title
           
            
        bjpvc.progress = { (current,duration) in
           
            result([
                "progress": current,
                "totalProgress": duration
            ])
        }
        
        
        
           let nvc = UINavigationController.init(rootViewController: bjpvc)
           
        
           let vc = UIApplication.shared.keyWindow?.rootViewController
           
           vc?.present(nvc, animated: true, completion: nil)
        
           
       }
    
    
    
    
    public func requestToken(withClassID classID: String, sessionID: String?, completion: @escaping (String?, Error?) -> Void) {
        
        print("requestToken")
        
        let key = "\(classID)-\(sessionID)"
        
        completion(key,nil)
        
    }
    
    public func requestToken(withVideoID videoID: String, completion: @escaping (String?, Error?) -> Void) {
        completion(videoID,nil)
    }
    
    
    
    
    
    
    
    
}

