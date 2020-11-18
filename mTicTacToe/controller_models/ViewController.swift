//
//  ViewController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 27/06/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    //  Outlets - UI elements
    
    @IBOutlet weak var BoardCollection: UICollectionView!
    @IBOutlet weak var currentPlayerImg: UIImageView!
    @IBOutlet weak var currentPlayerName: UILabel!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var player1Name: UILabel!
    @IBOutlet weak var player2Name: UILabel!
    
    let db = Firestore.firestore()
    var mode = Game.current.offline
    
    func setUpGame(gameMode:String, code:String, startWith:Int){
        self.mode =  gameMode
        GameBoard.game.gameMode = gameMode
        Game.current.code = code
        GameBoard.game.roomCode = code
        GameBoard.game.startingWith = startWith
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)

        self.navigationController?.navigationBar.tintColor = UIColor.white;

        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationItem.leftItemsSupplementBackButton = true

        BoardCollection?.delegate = self
        BoardCollection?.dataSource = self
        
        BoardCollection?.layer.borderColor = UIColor.orange.cgColor
        BoardCollection?.layer.cornerRadius = 10
        BoardCollection?.layer.borderWidth = 2
        
        infoBtn?.layer.cornerRadius = 10
        resetBtn?.layer.cornerRadius = 10
        undoBtn?.layer.cornerRadius = 10

        GameBoard.game.controller = self
        
        GameBoard.game.resetBoard()
        setCurrentPlayer(currentPlayer: 1)
        
        if(mode == Game.current.online){
            GameBoard.game.listenToDataUpdates()
            updatePlayerNames()
            
            if(Game.current.mode == "join"){
                resetBtn.isEnabled = false
                undoBtn.isEnabled = false

                resetBtn.backgroundColor = UIColor.gray
                resetBtn.setTitleColor(UIColor.orange, for: .normal)
            }
            
            undoBtn.backgroundColor = UIColor.gray
            undoBtn.setTitleColor(UIColor.orange, for: .normal)

        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(Core.shared.isNewUser()){
            //show onboard
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            
            vc.modalPresentationStyle = .fullScreen
            present(vc,animated: true)
        }
    }
    
    func updatePlayerNames(){
        player1Name?.text = Game.current.player1
        player2Name?.text = Game.current.player2
    }

    
    
    @IBAction func infoClicked(_ sender: Any) {
        InstructionsController.showPopup(parentVC: self)
    }
    
    func setCurrentPlayer(currentPlayer:Int) {
        updatePlayerNames()
        if(currentPlayer == GameBoard.game.playerX){
            currentPlayerImg?.image =  UIImage(named: "ic_x")
            currentPlayerName?.text = "\(Game.current.player1)'s turn"
        }else{
            currentPlayerImg?.image =  UIImage(named: "ic_o")
            currentPlayerName?.text = "\(Game.current.player2)'s turn"
        }
    }
    
    // Outlet actions
    
    @IBAction func resetBtnClicked(_ sender: Any) {

        if(!GameBoard.game.isGameEnded){
            
            let refreshAlert = UIAlertController(title: "Reset Game", message: "All progress will be lost.", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                
                
                if(GameBoard.game.gameMode == Game.current.online){
                                
                    GameBoard.game.resetBoard()
                    
                    print("\n manual reset performed \n")
                    
                    
                    if(GameBoard.game.startingWith == 2){
                        GameBoard.game.currentPlayer = 1
                        self.setCurrentPlayer(currentPlayer: GameBoard.game.playerX)
                    }else{
                        GameBoard.game.currentPlayer = 1
                        self.setCurrentPlayer(currentPlayer: GameBoard.game.playerX)
                    }
                    
                    
                    GameBoard.game.isGameEnded = false
                                
                    }
                else{
                    GameBoard.game.resetBoard()
                    GameBoard.game.updateCellViews()
                    self.setCurrentPlayer(currentPlayer: GameBoard.game.playerX)
                }
            }))

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Reset Cancelled")
              }))

            present(refreshAlert, animated: true, completion: nil)
        }else{
            if(GameBoard.game.gameMode == Game.current.online){
                
                GameBoard.game.resetBoard()
                
//                if(GameBoard.game.startingWith == 1){
//                    GameBoard.game.switchPlayer()
//                }
                
                print("\n manual reset performed \n")
                
                GameBoard.game.currentPlayer = 2
                self.setCurrentPlayer(currentPlayer: GameBoard.game.playerO)
                
                GameBoard.game.isGameEnded = false
                
            }else{
                GameBoard.game.resetBoard()
                GameBoard.game.updateCellViews()
                self.setCurrentPlayer(currentPlayer: GameBoard.game.playerX)
            }
        }
    }
    
    func updateRoomStatus(){
        if(GameBoard.game.gameMode == Game.current.online){
            if(!Game.current.roomExists){
                  let alert = UIAlertController(title: "Opponent left the game", message: "This room no longer exists", preferredStyle: UIAlertController.Style.alert)

                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    
                    Game.current.joined = 0
                    Game.current.connected = 0
                    Game.current.moved = false
                    GameBoard.game.gameMode = Game.current.offline
                    
                     self.navigationController?.popViewController(animated: true)
                 }))

                 self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func undoClicked(_ sender: Any) {
        
        if(GameBoard.game.totalPlayed > 1){
            GameBoard.game.undoMove()
        }
        
    }
    
    
    // MARK: CollectionView setup
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let height:CGFloat = UIScreen.main.bounds.height
        print("height is \(height)")
        
                if(height > 850){
                    collectionView.contentInset = UIEdgeInsets(top: height*0.085, left: 0, bottom: 0, right: 0)
                }
                else if(height > 800){
                    collectionView.contentInset = UIEdgeInsets(top: height*0.075, left: 0, bottom: 0, right: 0)
                }
                else if(height > 700){
                    collectionView.contentInset = UIEdgeInsets(top: height*0.02, left: 0, bottom: 0, right: 0)
                }
        
        GameBoard.game.collection = collectionView
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath) as! BoardCell
        cell.setUpCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGFloat = UIScreen.main.bounds.height
        
        var numberOfItemsPerRow:CGFloat = 6
        var spacingBetweenCells:CGFloat = 12
        
        if(height > 800){
            numberOfItemsPerRow = 6
            spacingBetweenCells = 12
        }
        else if(height > 700){
            
        }
        
       
        
        let totalSpacing = (2 * 6) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        let collection = collectionView
        if collection == collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(GameBoard.game.gameMode == Game.current.online){
            updateRoomStatus()
        }
        
        print("\n RIGHT NOW \(GameBoard.game.totalPlayed) played, \(GameBoard.game.currentPlayer), and start with \(GameBoard.game.startingWith)")
        
        let cell = indexPath.row
        let item:BoardCell = collectionView.cellForItem(at: indexPath) as! BoardCell
        
        GameBoard.game.updateBoardViewAtCell(cell: cell, view: item.img)
        
        if(GameBoard.game.isTimeToSwitchPlayer()){
            if(GameBoard.game.currentPlayer == GameBoard.game.playerX){
                self.setCurrentPlayer(currentPlayer: GameBoard.game.playerX)
            }else{
                self.setCurrentPlayer(currentPlayer: GameBoard.game.playerO)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("deininit")
            
        if(GameBoard.game.gameMode == Game.current.online){
            Game.current.roomExists = false
            db.collection("games").document(GameBoard.game.roomCode).delete() { err in
                
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                        print("Document successfully removed!")
                        Game.current.joined = 0
                        Game.current.connected = 0
                        Game.current.moved = false
                        GameBoard.game.gameMode = Game.current.offline
                }
            }
        }
    }
        
}

class Core{
    static let shared = Core()
    
    func isNewUser() -> Bool{
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
    
}

