//
//  Enums.swift
//  ReversiGame
//
//  Created by 佐藤一成 on 2021/12/19.
//

import SwiftUI
enum Direction:CaseIterable{
    case up,upRight,right,downRight,down,downLeft,left,upLeft
    var axis:(x:Int,y:Int){
        switch self {
        case .up:return (x: 0,y:-1)
        case .upRight:return (x: 1,y:-1)
        case .right:return (x: 1,y: 0)
        case .downRight:return (x: 1,y: 1)
        case .down:return (x: 0,y: 1)
        case .downLeft:return (x:-1,y: 1)
        case .left:return (x:-1,y: 0)
        case .upLeft:return (x:-1,y:-1)
        }
    }
}

enum Cell:Equatable{
    
    case stone(stone:Stone)
    case empty(deployable:Deployable)
    
    var stoneColor:Color{
        switch self{
        case .stone(stone: .black):return Color.black
        case .stone(stone: .white):return Color.white
        case .empty(_):return Color.clear
        }
    }
    // make bool for stone or empty
    var isStoneOn:Bool{
        switch self{
        case .stone(_):return true
        case .empty(_):return false
        }
    }
    
    enum Stone:CaseIterable{
        case black
        case white
        
        var cell:Cell{
            switch self{
            case .black:return .stone(stone: .black)
            case .white:return .stone(stone: .white)
            }
        }
        
        var opposed:Cell{
            switch self{
            case .black:return .stone(stone: .white)
            case .white:return .stone(stone: .black)
            }
        }
        var opposedPlayer:Stone{
            switch self{
            case .black:return .white
            case .white:return .black
            }
        }
        var emptyCell:Cell{
            switch self{
            case .black:return .empty(deployable: .black)
            case .white:return .empty(deployable: .white)
            }
        }
        
    }
    enum Deployable{
        case both
        case black
        case white
        case none
        
        var cell:Cell{
            switch self{
            case .both:return .empty(deployable: .both)
            case .black:return .empty(deployable: .black)
            case .white:return .empty(deployable: .white)
            case .none:return .empty(deployable: .none)
            }
        }
    }
    
}
enum Player:String{
    case black = "Black"
    case white = "White"
}
