//
//  game.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 08/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit
 
class Game{
    static let current = Game()
    
    let online = "online"
    let offline = "offline"
    
    var moved = false;
    
    var status:UILabel?
    var roomController:NewRoomViewcontroller?
    
    var code = "0000"
    var roomExists = true
    var connected = 0
    var joined = 0
    var player1 = "Player 1"
    var player2 = "Player 2"
    var mode = "none"
    
    func updateStatus(){
        if(mode == "new"){
            if(joined == 0){
                status?.text = "waiting for opponent to join"
            }else if(joined == 1){
                status?.text = "waiting for you to start the game"
                Game.current.roomExists = true
            }
        }else if(mode == "join"){
            print("\n joined righ now \(joined) \n")
            if(joined == 0){
                status?.text = "waiting for you to join"
            }else if(joined == 1){
                status?.text = "waiting for opponent to start the game"
            }else if(joined >= 2){
                if(!moved){
                    roomController?.goToGame()
                    moved = true
                }
            }
        }
    }

}
