//
//  MenuViewController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 07/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController:ViewController {
    
    @IBOutlet var menuButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for btn in menuButtons {
            btn.layer.borderColor = UIColor.orange.cgColor
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 2
            
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    @IBAction func instructionClicked(_ sender: Any) {
         let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
        
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated: true)
        //InstructionsController.showPopup(parentVC: self)
    }
    
}
