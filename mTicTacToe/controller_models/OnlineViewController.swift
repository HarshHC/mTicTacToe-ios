//
//  OnlineViewController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 07/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class OnlineViewController: UIViewController, UISearchTextFieldDelegate {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var enterCode: UITextField!
    
    let db = Firestore.firestore()
    var playerName = ""
    var code = ""
    var isJoinMode:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
       
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)

        self.navigationController?.navigationBar.tintColor = UIColor.white;

        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        for btn in buttons {
            btn.layer.borderColor = UIColor.orange.cgColor
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 2
        }
        
        enterCode.delegate = self
        
    }
    
    @IBAction func joinClicked(_ sender: Any) {
        let code_length = enterCode.text?.utf16.count ?? 0
        if(code_length == 4){
            print("good code")
            isCodeThereInDB(code: enterCode.text ?? "0000")
        }else{
            print("The entered code is wrong")
            showAlert(title: "Invalid Code", msg: "Room code should be 4 digits long")
        }
    }
    
    func isCodeThereInDB(code:String) {
        let docRef = db.collection("games").document(code)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                                
                let connections = document.get("connected") as! Int
            
                if(connections > 1){
                    self.showAlert(title: "Room is full", msg: "Try joining a different room or check your code")
                }else{
                    
                    
                    let player1 = document.get("player1") as! String
                    print(player1)

                    self.moveToRoom(playerName: player1, code: code)

                }
            } else {
                self.showAlert(title: "Invalid Code", msg: "Room does not exist")
            }
        }
    }
    
    func moveToRoom(playerName:String, code:String){
        
        isJoinMode = true
        self.playerName = playerName
        self.code = code
        performSegue(withIdentifier: "newRoomSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
    
        if(isJoinMode){
            if segue.identifier == "newRoomSegue",
               let newRoomVC = segue.destination as? NewRoomViewcontroller {
                Game.current.mode = "join"
                newRoomVC.setUpRoom(mode: "join", player1: playerName, player2: "player2", code: code)
            }
        }
    }
    
    func showAlert(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
        }))

        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        unsubscribeFromKeyboardNotifications()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
   }
   
   func subscribeToKeyboardNotifications() {
       
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
   }

   func unsubscribeFromKeyboardNotifications() {

       NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
   }
   
   @objc func keyboardWillShow(_ notification:Notification) {

       view.frame.origin.y = 100 - getKeyboardHeight(notification)
   }
   
   @objc func keyboardWillHide(_ notification:Notification) {

       view.frame.origin.y = 0
   }

   func getKeyboardHeight(_ notification:Notification) -> CGFloat {

       let userInfo = notification.userInfo
       let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
       return keyboardSize.cgRectValue.height
   }
    
}

