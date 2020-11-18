//
//  BoardCollectionVIewController.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 03/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit

class BoardCollectionVIewController:NSObject, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let height:CGFloat = UIScreen.main.bounds.height
        
                if(height > 700){
                    collectionView.contentInset = UIEdgeInsets(top: height*0.085, left: 0, bottom: 0, right: 0)
                }
       
        return 42
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath) as! BoardCell
        cell.setUpCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 6
        let spacingBetweenCells:CGFloat = 12
        
        let totalSpacing = (2 * 5) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        let collection = collectionView
        if collection == collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = indexPath.row
        let item:BoardCell = collectionView.cellForItem(at: indexPath) as! BoardCell
        
//        GameBoard.game.setBoardCell(cell: cell, player: GameBoard.game.playerX)
        GameBoard.game.updateBoardViewAtCell(cell: cell, view: item.img)
        
    }
    
}
