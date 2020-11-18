//
//  GameBoard.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 04/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GameBoard {
        
    static let game = GameBoard()
    
    let db = Firestore.firestore()
    
    var isGameEnded = false
    var roomCode = "0000"
    var gameMode = Game.current.offline
    
    let playerX = 1;
    let playerO = 2;
    
    var lastMove = 0
    var lastPlayer = 1
    
    var startingWith = 1
    
    var collection:UICollectionView?
    var controller:ViewController?
    var currentPlayer = 1;
    var totalPlayed = 0;
    
    var boardCells:[Int] = []
    var boardCells2d:[[Int]] = []
    var winPositions:[Int] = []

    func resetBoard(){
        boardCells = [Int](repeating: 0, count: 42)
        boardCells2d = Array(repeating: Array(repeating: 0, count: 6), count: 7)

        currentPlayer = 1;
        totalPlayed = 0;
        isGameEnded = false;
        winPositions.removeAll()
        
        if(gameMode == Game.current.online){
            pushBoardToDb()
        }
        
    }
    
    func undoMove(){
        if(!isGameEnded){
            totalPlayed -= 1
            let cellView = collection?.cellForItem(at: IndexPath(row: lastMove, section: 0)) as! BoardCell
            
            cellView.setUpCell()
            cellView.img.image = nil
            boardCells[lastMove] = 0
            currentPlayer = lastPlayer
        }
    
    }
    
    func updateCellViews(){
        for cell in 0...41 {
            
                if(!winPositions.contains(cell)){
                    if(!isGameEnded){

                        let cellView = collection?.cellForItem(at: IndexPath(row: cell, section: 0)) as! BoardCell
                                    cellView.setUpCell()
                                            
                        if(boardCells[cell] == playerX){
                            updateBoardViewAtCellWith(playerNum: playerX, cell: cell, view: cellView.img)
            //                cellView.img.image = UIImage(named: "ic_x")
                            cellView.backgroundColor = UIColor(white: 1, alpha: 0)
                        }else if(boardCells[cell] == playerO){
                            updateBoardViewAtCellWith(playerNum: playerO, cell: cell, view: cellView.img)
            //                cellView.img.image = UIImage(named: "ic_o")
            //                cellView.backgroundColor = UIColor(white: 1, alpha: 0)
                        }else{
                            cellView.img.image = nil
                        }
                    
                    }
                }else{
                    
                }
            
        
        }
    }
    
    func getBoardCells() -> [Int] {
        return boardCells
    }
    
    func setBoardCells(board:[Int]) {
        boardCells = board
    }
    
    func setBoardCell(cell:Int, player:Int) {
        boardCells[cell] = player
    }
    
    func getPlayerAtBoardCell(cell:Int) -> Int{
        return boardCells[cell]
    }
    
    func updateBoardViewAtCell(cell:Int, view:UIImageView) {
        
        print("\n IS GAME ENDED \(isGameEnded) \n")
        if(!isGameEnded){
            if(boardCells[cell] == 0){
               // print("done")
                
                if(gameMode == Game.current.online){
                    
                    if(currentPlayer == startingWith && startingWith == playerX){
                        view.image = UIImage(named: "ic_x")
                        view.backgroundColor = UIColor(white: 1, alpha: 0)
                        self.setBoardCell(cell: cell, player: playerX)
                        
                        chancePlayed()
                        pushBoardToDb()

                    }
                    else if(currentPlayer == startingWith && startingWith == playerO){
                        view.image = UIImage(named: "ic_o")
                        view.backgroundColor = UIColor(white: 1, alpha: 0)
                        self.setBoardCell(cell: cell, player: playerO)
                        
                        chancePlayed()
                        pushBoardToDb()

                    }
                }else{
                    
                    lastMove = cell
                    lastPlayer = currentPlayer
                    
                    if(currentPlayer == playerX){
                        view.image = UIImage(named: "ic_x")
                        view.backgroundColor = UIColor(white: 1, alpha: 0)
                        self.setBoardCell(cell: cell, player: playerX)
                    }
                    else if(currentPlayer == playerO){
                        view.image = UIImage(named: "ic_o")
                        view.backgroundColor = UIColor(white: 1, alpha: 0)
                        self.setBoardCell(cell: cell, player: playerO)
                    }
                    
                    chancePlayed()

                }
                
                //print(boardCells)
                
                if(totalPlayed > 8){
                    checkForWins()
                }
            }
        }
    }
    
    func updateBoardViewAtCellWith(playerNum:Int, cell:Int, view:UIImageView) {

        controller?.updateRoomStatus()
    
        print("\n WE ARE NOT IN \n")

        if(!isGameEnded){
            
            print("\n WE AE IN \n")

            if(playerNum == playerX){
                view.image = UIImage(named: "ic_x")
                view.backgroundColor = UIColor.black
                self.setBoardCell(cell: cell, player: playerX)
                print("\n JUST PLAYED X \n")

            }
            else if(playerNum == playerO){
                view.image = UIImage(named: "ic_o")
                view.backgroundColor = UIColor.black
                self.setBoardCell(cell: cell, player: playerO)
                print("\n JUST PLAYED O \n")

            }
                        

            //print(boardCells)
            
            if(totalPlayed > 8){
                checkForWins()
            }
            
        }
    }
    
    func convertBoardTo2D() {
        for i in 0...6{
            for j in 0...5{
                boardCells2d[i][j] = boardCells[(6*i)+j]
                //print(boardCells[(6*i)+j])
            }
            //print("****")
        }
        
      //  print(boardCells2d)
    }
    
    func chancePlayed() {
        
        totalPlayed = totalPlayed + 1;
        
        if(gameMode == Game.current.offline){
            if(isTimeToSwitchPlayer()){
                switchPlayer()
            }
        }
    
    }
    
    func isTimeToSwitchPlayer() -> Bool {
        if(totalPlayed%2 == 0){
            return true
        }else{
            return false
        }
    }
    
    func switchPlayer() {

        if(currentPlayer == playerX){
            currentPlayer = playerO
        }else{
            currentPlayer = playerX
        }
        
        controller?.setCurrentPlayer(currentPlayer: currentPlayer)
    }
    
    func checkForWins(){

        if(!isGameEnded){
            
            // checking wins in row starting at first col
            for i in stride(from: 0, to: 42, by: 6) {
                checkWinInRow(startingAtCell: i)
            }
            
            // checking wins in row starting at second col
            for i in stride(from: 1, to: 42, by: 6) {
                checkWinInRow(startingAtCell: i)
            }
            
            // checking in all columns for X and O
            checkWinInColumn(checkPlayer: playerX)
            checkWinInColumn(checkPlayer: playerO)
            
            // checking diagonally for X
            checkWinsDiagonally(startingAtRow: 0, startingAtCol: 0, max: 5, checkFor: playerX)
            checkWinsDiagonally(startingAtRow: 0, startingAtCol: 1, max: 4, checkFor:  playerX)
            checkWinsDiagonally(startingAtRow: 1, startingAtCol: 0, max: 5, checkFor: playerX)
            checkWinsDiagonally(startingAtRow: 2, startingAtCol: 0, max: 4, checkFor: playerX)
            
            // checking diagonally for O
            checkWinsDiagonally(startingAtRow: 0, startingAtCol: 0, max: 5, checkFor: playerO)
            checkWinsDiagonally(startingAtRow: 0, startingAtCol: 1, max: 4, checkFor:  playerO)
            checkWinsDiagonally(startingAtRow: 1, startingAtCol: 0, max: 5, checkFor: playerO)
            checkWinsDiagonally(startingAtRow: 2, startingAtCol: 0, max: 4, checkFor: playerO)
            
            // checking inverse diagonally for X
            checkWinsDiagonallyInverse(startingAtRow: 0, startingAtCol: 5, max: 5, checkFor: playerX)
            checkWinsDiagonallyInverse(startingAtRow: 0, startingAtCol: 4, max: 4, checkFor: playerX)
            checkWinsDiagonallyInverse(startingAtRow: 1, startingAtCol: 5, max: 5, checkFor: playerX)
            checkWinsDiagonallyInverse(startingAtRow: 2, startingAtCol: 5, max: 4, checkFor: playerX)
            
            // checking inverse diagonally for O
            checkWinsDiagonallyInverse(startingAtRow: 0, startingAtCol: 5, max: 5, checkFor: playerO)
            checkWinsDiagonallyInverse(startingAtRow: 0, startingAtCol: 4, max: 4, checkFor: playerO)
            checkWinsDiagonallyInverse(startingAtRow: 1, startingAtCol: 5, max: 5, checkFor: playerO)
            checkWinsDiagonallyInverse(startingAtRow: 2, startingAtCol: 5, max: 4, checkFor: playerO)
           
        }
        
        

    }
    
    func checkWinInRow(startingAtCell:Int){
        
        if(!isGameEnded){
            winPositions.removeAll()

            let checkForItem = boardCells[startingAtCell]
            var totalChecks = 0;
                    
            if(checkForItem != 0){
                for i in startingAtCell...startingAtCell+4{
                    if(boardCells[i] == checkForItem){
                        totalChecks+=1
                        winPositions.append(i)
                    }else{
                        totalChecks = 0
                        winPositions.removeAll()
                        return
                    }
                }
                
                if(totalChecks == 5){
                    highlightWinPositions(winner: checkForItem)
                }
            }
        }
    }
    
    func checkWinInColumn(checkPlayer:Int){

        if(!isGameEnded){
            
            winPositions.removeAll()
            convertBoardTo2D()
                    
            let checkForItem = checkPlayer
            var totalChecks = 0
            
            if(checkForItem != 0){
                
                colLoop: for col in 0...5 {
                    if(totalChecks == 5){
    //                    print(winPositions)
                        highlightWinPositions(winner: checkForItem)
                    }else{
                        totalChecks =   0
                    }
                    for row in 0...6 {
    //                        print(" \(row), \(col) -> \(boardCells2d[row][col])")
                        if(boardCells2d[row][col] == checkForItem){
                            if(totalChecks<5){
                                totalChecks+=1
                                winPositions.append((6*row)+col)
                            }
                        }else{
                            if(totalChecks < 5){
                                totalChecks = 0
                                winPositions.removeAll()
                            }
                        }
                        
                    }
                    //print("column done")
                }
            }
                
              //  print("tot checks: \(totalChecks)")
            
            if(totalChecks == 5){
                print(winPositions)
                highlightWinPositions(winner: checkForItem)
                totalChecks = 0
            }
        }
        
    }
    
    func checkWinsDiagonally(startingAtRow:Int, startingAtCol:Int, max:Int, checkFor:Int){
        
        if(!isGameEnded){
                
            convertBoardTo2D()
            
           // print("next check")
            winPositions.removeAll()
            
            var row = startingAtRow
            var col = startingAtCol
            
            let checkForItem = checkFor
        
            var totalChecks = 0

            for _ in 0...max {
              //  print("\(totalChecks)")

             //   print("\(row),\(col) -> \(boardCells2d[row][col]) looking for \(checkForItem) \n")

                if(boardCells2d[row][col] == checkForItem){
             //       print("\nfound a match")
                    if(totalChecks < 5){
                        totalChecks+=1
                        winPositions.append((6*row)+col)
             //           print("total checks is \(totalChecks)")
                    }else{
             //           print(winPositions)
                        highlightWinPositions(winner: checkForItem)
                        totalChecks = 0
                    }
                }else{
                    totalChecks = 0
                    winPositions.removeAll()
                }
                
                if(totalChecks == 5){
            //        print(winPositions)
                    highlightWinPositions(winner: checkForItem)
                    totalChecks = 0
                }
                
                row+=1
                col+=1
          //      print("next diagonal element")
            }
        }
    }
    
    func checkWinsDiagonallyInverse(startingAtRow:Int, startingAtCol:Int, max:Int, checkFor:Int){
        
        if(!isGameEnded){
                
            convertBoardTo2D()
            
            print("next check")
            winPositions.removeAll()
            
            var row = startingAtRow
            var col = startingAtCol
            
            let checkForItem = checkFor
        
            var totalChecks = 0

            for _ in 0...max {
                print("\(totalChecks)")

                print("\(row),\(col) -> \(boardCells2d[row][col]) looking for \(checkForItem) \n")

                if(boardCells2d[row][col] == checkForItem){
                    print("\nfound a match")
                    if(totalChecks < 5){
                        totalChecks+=1
                        winPositions.append((6*row)+col)
                        print("total checks is \(totalChecks)")
                    }else{
                        print(winPositions)
                        highlightWinPositions(winner: checkForItem)
                        totalChecks = 0
                    }
                }else{
                    totalChecks = 0
                    winPositions.removeAll()
                }
                
                if(totalChecks == 5){
                    print(winPositions)
                    highlightWinPositions(winner: checkForItem)
                    totalChecks = 0
                }
                
                row+=1
                col-=1
                print("next inverse diagonal element")
            }
        }
    }
    
    func highlightWinPositions(winner:Int){
        
        if(winner == playerX){
            for i in 0...4{
                 let cellView = collection?.cellForItem(at: IndexPath(row: winPositions[i], section: 0)) as! BoardCell
                
                cellView.setUpCell()
                cellView.img.backgroundColor = UIColor.black
                cellView.img.image = UIImage(named: "win_x")
            }
        }else if(winner == playerO){
            for i in 0...4{
                 let cellView = collection?.cellForItem(at: IndexPath(row: winPositions[i], section: 0)) as! BoardCell
                
                cellView.setUpCell()
                cellView.img.backgroundColor = UIColor.black
                cellView.img.image = UIImage(named: "win_o")
            }
        }
        
        isGameEnded = true
    }
    
    func listenToDataUpdates(){
        print("hi")
        db.collection("games").document(GameBoard.game.roomCode)
        .addSnapshotListener {documentSnapshot, error in
          guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
          }
          guard let data = document.data() else {
            print("Document data was empty.")
            Game.current.roomExists = false

            return
          }
            
            print("Current data: \(data)")
            
            print("updated")
            
            Game.current.connected = document.get("connected") as! Int
            Game.current.joined = document.get("joined") as! Int
            Game.current.player1 = document.get("player1") as! String
            Game.current.player2 = document.get("player2") as! String
            GameBoard.game.boardCells = document.get("board") as! [Int]
            GameBoard.game.totalPlayed = document.get("chancesPlayed") as! Int

            GameBoard.game.updateCellViews()
            
            if(GameBoard.game.isTimeToSwitchPlayer()){
                GameBoard.game.switchPlayer()
            }
            
            if(GameBoard.game.totalPlayed < 8){
                GameBoard.game.isGameEnded = false
            }
            
            if(GameBoard.game.totalPlayed == 0){
                GameBoard.game.winPositions.removeAll()

                GameBoard.game.currentPlayer = GameBoard.game.playerX
                GameBoard.game.controller?.setCurrentPlayer(currentPlayer: GameBoard.game.playerX)
            }
            
            
            if(GameBoard.game.totalPlayed == 1){
                 GameBoard.game.winPositions.removeAll()
            }
            
        }
    }
    
    func pushBoardToDb(){
        let gameRoom = db.collection("games").document(roomCode)
        
        gameRoom.updateData([
            "board": boardCells,
            "chancesPlayed": totalPlayed
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    
}
