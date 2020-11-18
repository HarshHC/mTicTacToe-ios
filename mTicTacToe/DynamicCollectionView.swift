//
//  DynamicCollectionView.swift
//  mTicTacToe
//
//  Created by Harsh Chandra on 03/07/20.
//  Copyright © 2020 HC ingenoVations. All rights reserved.
//

import Foundation
import UIKit

class DynamicCollectionView:UICollectionView{
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
        
        //print("called")
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }}
