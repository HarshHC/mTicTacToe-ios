//
//  InstructionsController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 11/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit

class InstructionsController:UIViewController {
    
    @IBOutlet weak var main: UIView!
    @IBOutlet weak var mainText: UILabel!
    
    @IBOutlet weak var xButton: UIButton!
    
    static let identifier = "InstructionsController"
    var text = "This game is a modified version of the famous Tic Tac Toe Game (X and O) \nIn the Game the first player plays TWO chances at a time followed by the second player's two turns. \n\nThe player to first GET 5 in a row in any direction (vertical / horizontal / diagonal) wins the game! \n\nWhenever a player wins, the squares are highlighted to declare the winner"
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        
        main.layer.borderColor = UIColor.orange.cgColor
        main.layer.cornerRadius = 10
        main.layer.borderWidth = 2
        
        xButton.layer.cornerRadius = 8
        
        mainText.text = text
        mainText.lineBreakMode = .byWordWrapping
        mainText.numberOfLines = 0

    }
    
    static func showPopup(parentVC: UIViewController){
      //creating a reference for the dialogView controller
      if let popupViewController = UIStoryboard(name: "InstructionsView", bundle: nil).instantiateViewController(withIdentifier: "InstructionsController") as? InstructionsController {
      popupViewController.modalPresentationStyle = .custom
      popupViewController.modalTransitionStyle = .crossDissolve
      //presenting the pop up viewController from the parent viewController
      parentVC.present(popupViewController, animated: true)
      }
    }
    
    @IBAction func HCclicked(_ sender: Any) {
        if let url = URL(string: "https://www.instagram.com/harshhc5") {

        UIApplication.shared.open(url)
        }
    }
    
    
    @IBAction func xClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
