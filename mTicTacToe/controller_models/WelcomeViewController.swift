//
//  WelcomeViewController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 07/08/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController:UIViewController{
    
    @IBOutlet weak var holderView: UIView!
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configure()
    }
    
    func configure(){
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)
        
        let titles = ["Welcome", "How-to-Play","Winning"]
        let descriptions = ["mTicTacToe is a modified version of the famous Tic Tac Toe game that is played on a 7x6 grid",
            "Each player gets to play 2 chances at once",
            "First player to get 5 in a row in any direction WINS the game!"]
        let images = ["welcome_1","welcome_2","welcome_3"]
        let buttons = ["NEXT","NEXT","START"]

        
        for i in 0..<3{
            
            let pageView = UIView(frame: CGRect(x: CGFloat(CGFloat(i)*(holderView.frame.size.width)), y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            
            var h = holderView.frame.size.height
            var w = holderView.frame.size.width
            
            let height:CGFloat = UIScreen.main.bounds.height
            print(height)
            
            if(height < 850){
                h = h - 30
                w = w - 30
            }
            
            if(height < 750){
                h = height
                w = w + 20
            }
            
            if(height < 700){
                h = height
                w = holderView.frame.size.width
            }
            
            if(height < 670){
                h = height
                w = w - 35
            }
        
            let label = UILabel(frame: CGRect(x: (w-(w - (w/5)))/2, y: (h*0.01), width: w - (w/5), height: (h*0.10)))
            
            let image = UIImageView(frame: CGRect(x: (w - (w*0.9))/2, y: (h*0.12), width: (w*0.9), height: (h*0.5)) )
            
            var desc = UILabel(frame: CGRect(x: ((w*0.15))/2, y: (h*0.55), width: w - (w*0.15), height: 300))
            
            if(height < 700){
                desc = UILabel(frame: CGRect(x: ((w*0.15))/2, y: (h*0.5), width: w - (w*0.15), height: 300))
            }
            
            let button = UIButton(frame: CGRect(x: (w - (w*0.5))/2, y: h - (h*0.15), width: w*0.5, height: 50))
            
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica-Bold", size: 32)
            label.text = titles[i]
            label.textColor = .white
            
            image.contentMode = .scaleAspectFit
            image.image = UIImage(named: images[i])
            

            desc.textAlignment = .center
            desc.numberOfLines = 3
            desc.font = UIFont(name: "Helvetica-Bold", size: 20)
            desc.text = descriptions[i]
            desc.textColor = .white
            
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            
            button.setTitle(buttons[i], for: .normal)
            button.tag = i+1
            button.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
            
            pageView.addSubview(label)
            pageView.addSubview(image)
            pageView.addSubview(desc)
            pageView.addSubview(button)
            
            scrollView.addSubview(pageView)
        }
        
        scrollView.contentSize = CGSize(width: holderView.frame.size.width*3, height: 0)
        scrollView.isPagingEnabled = true
    }
     
    @objc func btnTapped(_ button: UIButton){
        guard button.tag < 3 else{
            Core.shared.setIsNotNewUser()
            dismiss(animated: false, completion: nil)
            return
        }
        
        var h = holderView.frame.size.height
        var w = holderView.frame.size.width
        
        let height:CGFloat = UIScreen.main.bounds.height
        print(height)
        
        if(height < 850){
            h = h - 30
            w = w - 30
        }
        
        if(height < 820){
            w = UIScreen.main.bounds.width + 40
        }
        
        if(height < 750){
            w =  UIScreen.main.bounds.width
        }
        
        if(height < 700){
            w =  UIScreen.main.bounds.width + 40
        }
                
        scrollView.setContentOffset(CGPoint(x: w * (CGFloat(button.tag)), y: 0), animated: true)
   }
    
}
