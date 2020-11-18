//
//  NewRoomViewController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 07/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewRoomViewcontroller:UIViewController, UISearchTextFieldDelegate {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var codeInfoLabel: UILabel!
    @IBOutlet weak var gameStatus: UILabel!
    
    let db = Firestore.firestore()
    var isGameStarting = false
    
    var mode = "new"
    var player1 = "player1"
    var player2 = "player2"
    var gameCode = "0000"
    var connected = 0
    var joined = 0
    
    func setUpRoom(mode:String, player1:String, player2:String, code:String ){
        self.mode = mode
        self.player1 = player1
        self.player2 = player2
        self.gameCode = code
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)

        self.navigationController?.navigationBar.tintColor = UIColor.white;

        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        startBtn.layer.borderColor = UIColor.orange.cgColor
        startBtn.layer.cornerRadius = 10
        startBtn.layer.borderWidth = 2
        
        playerName.delegate = self
        
        Game.current.status = gameStatus
        Game.current.roomController = self
        
        if(mode == "new") {
            Game.current.roomExists = true
            Game.current.mode = "new"
            var code = generateRoomCode()
            self.gameCode = code

            db.collection("games").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if(document.documentID == code){
                            code = self.generateRoomCode()
                        }
                       // print("\(document.documentID) => \(document.data())")
                    }
                    
                   // run
                    self.createGameInDB(code: code)
                }
            }
        }else if(mode == "join"){
            
            codeLabel?.text = "ROOM CODE: \(gameCode)"
            playerName.text = player2
            startBtn.setTitle("READY", for: .normal)
            gameStatus.text = "waiting for you to join the game"
            Game.current.roomExists = true

            let gameRoom = db.collection("games").document(gameCode)

            gameRoom.updateData([
                "connected": 2
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        
        listenToDataUpdates()
        
    }
    
    func listenToDataUpdates(){
        print("hi")
        db.collection("games").document(gameCode)
        .addSnapshotListener {documentSnapshot, error in
          guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
          }
          guard let data = document.data() else {
            print("Document data was empty.")
            
            if(!Game.current.roomExists){
                let alert = UIAlertController(title: "Room No Longer exists", message: "The room creater deleted the room", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewController(animated: true)

                }))

                self.present(alert, animated: true, completion: nil)
            }
            
            if(Game.current.mode == "join"){
                Game.current.roomExists = false
            }
            
            
            return
          }
            
            print("Current data: \(data)")
            
            print("updated")
            
            Game.current.connected = document.get("connected") as! Int
            Game.current.joined = document.get("joined") as! Int
            print("Joined \(Game.current.joined)")
            Game.current.updateStatus()
        }
    }
    
    @IBAction func startClicked(_ sender: Any) {
        
        if(!Game.current.roomExists){
            let alert = UIAlertController(title: "Room No Longer exists", message: "The room creater deleted the room", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)

            }))

            self.present(alert, animated: true, completion: nil)
        }
        
        if(mode == "new"){
            if(Game.current.joined < 1){
                showAlert(title: "Not enough players", msg: "Opponent has not joined the game or entered the room")
            }else{
                let name_length = playerName.text?.utf16.count ?? 0
                let name:String = playerName.text ?? "player1"

                if(name_length < 15){
                    player1 = name
                }else{
                    player1 = String(name.prefix(15))
                }
                if(name.isEmpty){
                    player1 = "player1"
                }
                
                let gameRoom = db.collection("games").document(gameCode)

                gameRoom.updateData([
                    "joined": Game.current.joined+1,
                    "player1": player1
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                // start the game
                isGameStarting = true
                
                if(Game.current.roomExists){
                    performSegue(withIdentifier: "startTheGame", sender: self)
                }else{
                    let alert = UIAlertController(title: "Room No Longer exists", message: "The room creater deleted the room", preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        self.navigationController?.popViewController(animated: true)

                    }))

                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }else if(mode == "join"){
            
            if(!Game.current.roomExists){
                  let alert = UIAlertController(title: "Room No Longer exists", message: "The room creater deleted the room", preferredStyle: UIAlertController.Style.alert)

                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                     self.navigationController?.popViewController(animated: true)

                 }))

                 self.present(alert, animated: true, completion: nil)
            }

            if(Game.current.joined < 1){
                let gameRoom = db.collection("games").document(gameCode)
                
                let name_length = playerName.text?.utf16.count ?? 0
                let name:String = playerName.text ?? "player2"

                if(name_length < 15){
                    player2 = name
                }else{
                    player2 = String(name.prefix(15))
                }
                if(name.isEmpty){
                    player2 = "player2"
                }
                
                gameRoom.updateData([
                    "joined": Game.current.joined+1,
                    "player2": player2
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                
                gameStatus.text = "waiting for room creator to start the game"
            }
            
        }
    }
    
    func goToGame(){
        if(Game.current.roomExists){
            performSegue(withIdentifier: "startTheGame", sender: self)
        }else{
            let alert = UIAlertController(title: "Room No Longer exists", message: "The room creater deleted the room", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)

            }))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func generateRoomCode() -> String{
        return String(1000+arc4random_uniform(8999))
    }
    
    func showAlert(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {

        if(mode == "new"){
            if segue.identifier == "startTheGame",
               let newGame = segue.destination as? ViewController {
                newGame.setUpGame(gameMode: Game.current.online, code: gameCode, startWith: GameBoard.game.playerX)
            }
        }else if(mode == "join"){
             if segue.identifier == "startTheGame",
                          let newGame = segue.destination as? ViewController {
                           newGame.setUpGame(gameMode: Game.current.online, code: gameCode, startWith: GameBoard.game.playerO)
            }
        }
        

    }

    func createGameInDB(code:String){
        
        gameCode = code
        GameBoard.game.roomCode = code
        GameBoard.game.resetBoard()
        let blank_gameboard = GameBoard.game.boardCells
        
        codeLabel.text = "ROOM CODE: \(GameBoard.game.roomCode)"
        
         db.collection("games").document(code).setData([
             "player1": "player1",
             "player2": "player2",
             "connected": 1,
             "joined": 0,
             "board": blank_gameboard,
             "chancesPlayed": 0
         ]) { err in
             if let err = err {
                 print("Error writing document: \(err)")
             } else {
                 print("\nDocument successfully written!\n")
             }
         }
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
    
    func shareTextButton() {

        // text to share
        let text = "Join my mTicTacToe game now! Room code: \(gameCode)"

        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash 

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("deininit")
        if(!isGameStarting){
            
            if(mode == "new"){
                db.collection("games").document(gameCode).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }else{
                let gameRoom = db.collection("games").document(gameCode)
                
                if(Game.current.joined != 0){
                    Game.current.joined -= 1
                }

                gameRoom.updateData([
                    "connected": Game.current.connected - 1,
                    "joined": Game.current.joined
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            }
            
        }
    }
    
}
