//
//  BJYDBViewController.swift
//  BJLiveBase
//
//  Created by 胡杰 on 2019/10/26.
//

import Foundation
import BJVideoPlayerUI



class BJYDBViewController: UIViewController{
    
    var bjtitle:String = ""
    var videoId:String = ""
    var token:String = ""
    var bjpvc:BJPUViewController?
    
    
    var defaultStatusBarStyle :UIStatusBarStyle? ;
    var topBarBG:UIColor?;
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = defaultStatusBarStyle ?? UIStatusBarStyle.lightContent
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor.white
        self.title = bjtitle
        addBJPUView()
        
        
    }
    
    
    
    
    func addBJPUView(){

         let options = BJPUVideoOptions.init()
         bjpvc = BJPUViewController.init(videoOptions: options)
         
         self.addChildViewController(bjpvc!)
         bjpvc!.didMove(toParentViewController: self)
         
        self.view.addSubview(bjpvc!.view)
         
        let topView = bjpvc!.view.subviews[3]
        topView.subviews[0].isHidden = true
        
        topBarBG = topView.backgroundColor
        
        topView.backgroundColor = UIColor.clear
        
        
        
        let this = self
        bjpvc?.cancelCallback = {
            
            this.dismiss(animated: true, completion: nil)
    
        }
        
        addBackBtn()
        
        addNotificationAction()
       
        
        bjpvc!.play(withVid: videoId, token: token)
    }
    
    func addBackBtn(){
        
        let image =  UIImage.init(named: "resource.bundle/close")?.withRenderingMode(.alwaysOriginal)
        
        
        print(image?.size)
        
        
        
        
        let backBtn = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(backBtnClick))
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func backBtnClick(){
        self.dismiss(animated: true, completion: nil)
    }
    

    func addNotificationAction(){
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    
    @objc func deviceOrientationDidChange(noti:Notification )
    {
        if(UIDevice.current.orientation == UIDeviceOrientation.portrait){
            let topView = bjpvc!.view.subviews[3]
            topView.subviews[0].isHidden = true
            topView.backgroundColor = UIColor.clear
             self.navigationController?.setNavigationBarHidden(false, animated: false)
        }else{
            let topView = bjpvc!.view.subviews[3]
            topView.subviews[0].isHidden = false
            topView.backgroundColor = topBarBG
             self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    
    override func updateViewConstraints() {
        let size = self.view.bounds.size
        
        let isHorizontal = size.width > size.height
        self.updateConstraintsForHorizontal(isHorizontal: isHorizontal)
        super.updateViewConstraints()
        
    }
    
   
    
    
    
    func updateConstraintsForHorizontal(isHorizontal:Bool){
        
        if(isHorizontal){
            bjpvc?.view.bjl_remakeConstraints({ (mark:BJLConstraintMaker) in
                mark.edges.equalTo(self.view)
            })
        }else{
            bjpvc?.view.bjl_remakeConstraints({ (mark:BJLConstraintMaker) in
                mark.top.equalTo(self.view).offset(0)
                mark.left.right.equalTo((self.view.bjl_safeAreaLayoutGuide != nil) ? self.view.bjl_safeAreaLayoutGuide : self.view)
                mark.height.equalTo(self.bjpvc?.view.bjl_width).multipliedBy(9.0/16.0)
            })
        }
        
        
    }
    
}

