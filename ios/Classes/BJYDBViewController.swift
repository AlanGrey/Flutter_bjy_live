//
//  BJYDBViewController.swift
//  BJLiveBase
//
//  Created by 胡杰 on 2019/10/26.
//

import Foundation




class BJYDBViewController: UIViewController{
    
    var bjtitle:String = ""
    var videoId:String = ""
    var token:String = ""
    var bjpvc:BJPUViewController?
    
    var progress: ((Int,Int) -> Void)?;
    
    
    var defaultStatusBarStyle :UIStatusBarStyle? ;
    var topBarBG:UIColor?;
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        defaultStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = defaultStatusBarStyle ?? UIStatusBarStyle.lightContent
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = bjtitle
        addBJPUView()
        
        
    }
    
    
    
    
    func addBJPUView(){

         let options = BJPUVideoOptions.init()
         options.playTimeRecordEnabled = true
        
        
         bjpvc = BJPUViewController.init(videoOptions: options)
        self.addChild(bjpvc!)
        bjpvc!.didMove(toParent: self)
        
        
    
         
        self.view.addSubview(bjpvc!.view)
        
        let uilabel = bjpvc?.topBarView.viewWithTag(111) as? UILabel
        uilabel?.text = bjtitle
    
        bjpvc?.cancelCallback = {
            self.dismiss(animated: true, completion: nil)
        }
        
    
        
        bjpvc!.play(withVid: videoId, token: token)
    }
    
    
    
   
    
    
    
    override func updateViewConstraints() {
        let size = self.view.bounds.size
        
        let isHorizontal = size.width > size.height
        self.updateConstraintsForHorizontal(isHorizontal: isHorizontal)
        super.updateViewConstraints()
        
    }
    
    func isHoriztontal() -> Bool {
        let size = self.view.bounds.size
        
        let isHorizontal = size.width > size.height
        return isHorizontal
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

