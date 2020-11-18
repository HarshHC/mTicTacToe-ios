//
//  BoardCell.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 03/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit

class BoardCell:UICollectionViewCell{
    
    @IBOutlet weak var img: UIImageView!
    
    func setUpCell() {
        img.layer.cornerRadius = 8
        img.layer.backgroundColor = UIColor.white.cgColor
    }
    
}
