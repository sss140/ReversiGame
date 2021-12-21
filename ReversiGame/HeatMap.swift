//
//  HeatMap.swift
//  ReversiGame
//
//  Created by 佐藤一成 on 2021/12/19.
//

import SwiftUI

extension ReversiGame{
     func scoresInitialize(){
        self.scores.removeAll()
        let row:[Int?] = [Int?](repeating: nil, count: 8)
        self.scores = [[Int?]](repeating: row, count: 8)
    }
    private func addScore(_ pos:Pos,score:Int){
        guard let cellScore = self.scores[pos.x][pos.y] else{
            self.scores[pos.x][pos.y] = score
            return
        }
        self.scores[pos.x][pos.y] = cellScore + score
    }
    
    
    
    func setRefPoints(){
        refPoints.append([100,-20,001,001,001,001,-20,100])
        refPoints.append([-20,-20,001,001,001,001,-10,-20])
        refPoints.append([001,001,001,001,001,001,001,001])
        refPoints.append([001,001,001,000,000,001,001,001])
        refPoints.append([001,001,001,000,000,001,001,001])
        refPoints.append([001,001,001,001,001,001,001,001])
        refPoints.append([-20,-20,001,001,001,001,-20,-20])
        refPoints.append([100,-20,001,001,001,001,-20,100])
    }
    
    
    func getScoreString(score:Int?)->String{
        guard let score = score else{
            return ""
        }
        return "\(score>0 ? "+":"")\(score)"
    }
    
    private func getScore(indexPos:Pos,cells:[[Cell]],pos:Pos,stone:Cell.Stone,rec:Int){
        guard rec>0 else{return}
        let indexInt:Int = (stone == self.player ? 1:-1)
        addScore(indexPos, score: 5 * refPoints[pos.x][pos.y] * indexInt)
        
        var dummyCells = cells
        var turningStones = getTurningStones(cells: cells, pos: pos, stone: stone)
        turningStones.append(pos)
        for turnPos in turningStones{
            dummyCells[turnPos.x][turnPos.y] = stone.cell
        }
        let deployablePositions = checkAllCellsAndGetDeployablePositions(cells: dummyCells) { pos, cell in
            dummyCells[pos.x][pos.y] = cell
        }
        let stoneCounts = countStones(cells: dummyCells)
        var nextStone:Cell.Stone = player
        switch (black:deployablePositions.black.count>0,white:deployablePositions.white.count>0){
        case (black:true,white:true):
            //do nothing
            nextStone = stone.opposedPlayer
        case (black:true,white:false):
            addScore(indexPos, score: (player == .black ? 300:-300) * indexInt)
            nextStone = Cell.Stone.black
            return
        case (black:false,white:true):
            addScore(indexPos, score: (player == .white ? 300:-300) * indexInt)
            nextStone = Cell.Stone.white
            return
        case (black:false,white:false):
            switch player{
            case .black:
                addScore(indexPos, score: (stoneCounts.white<stoneCounts.black ? 500:-500) * indexInt)
            case .white:
                addScore(indexPos, score: (stoneCounts.white>stoneCounts.black ? 500:-500) * indexInt)
            }
           return
        }
        
        var myOppPos:[Pos] = []
        
        switch nextStone{
        case .black:
            myOppPos = deployablePositions.black
        case .white:
            myOppPos = deployablePositions.white
        }
        
        for oppPos in myOppPos{
            addScore(indexPos,score:refPoints[oppPos.x][oppPos.y] * 1 * indexInt)
            getScore(indexPos: indexPos, cells: dummyCells, pos: oppPos, stone: nextStone, rec: rec-1)
        }
        //addScore(indexPos, score: myOppPos.count * 1 * indexInt)
    }
    
    
    func makeHeatMap(){
        scoresInitialize()
        let myStone:Cell.Stone = player
        var dummyCells = self.cells
        let deployablePositions = checkAllCellsAndGetDeployablePositions(cells: dummyCells) { pos, cell in
            dummyCells[pos.x][pos.y] = cell
        }
        let myDeployablePos = myStone == .black ? deployablePositions.black:deployablePositions.white
        for myPos in myDeployablePos{
            getScore(indexPos: myPos, cells: dummyCells, pos: myPos, stone: myStone,rec:2)
        }
        let max = self.scores.flatMap { $0.compactMap {$0}}.max()
        var maxArr:[Pos] = []
        for x in 0..<8{
            for y in 0..<8{
                if scores[x][y] == max{
                    maxArr.append((x:x,y:y))
                }
            }
        }
        maxArr.shuffle()
        self.deployPosition = maxArr[0]
        
    }
    
    
    
    func printCells(cells:[[Cell]]){
        for y in 0..<8{
            var str:String = ""
            for x in 0..<8{
                switch cells[x][y]{
                case .stone(stone:.black):str += "○"
                case .stone(stone:.white):str += "●"
                case .empty(deployable: .both): str += "両"
                case .empty(deployable: .black): str += "黒"
                case .empty(deployable: .white): str += "白"
                case .empty(deployable: .none): str += "＿"
                }
            }
            print (str)
        }
        print("")
    }
    
}
