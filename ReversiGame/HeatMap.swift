//
//  HeatMap.swift
//  ReversiGame
//
//  Created by 佐藤一成 on 2021/12/19.
//

import SwiftUI

extension ReversiGame{
    private func scoresInitialize(){
        self.scores.removeAll()
        let row:[Int?] = [Int?](repeating: nil, count: 8)
        self.scores = [[Int?]](repeating: row, count: 8)
    }
    
    func setRefPoints(){
        refPoints.append([100,-20,001,001,001,001,-20,100])
        refPoints.append([-20,-20,001,001,001,001,-10,-20])
        refPoints.append([001,001,001,001,001,001,001,001])
        refPoints.append([001,001,001,000,000,001,001,001])
        refPoints.append([001,001,001,000,000,001,001,001])
        refPoints.append([001,001,001,001,001,001,001,001])
        refPoints.append([-10,-10,001,001,001,001,-20,-20])
        refPoints.append([100,-10,001,001,001,001,-20,100])
    }
    
    
    func getScoreString(score:Int?)->String{
        guard let score = score else{
            return ""
        }
        return "\(score>0 ? "+":"")\(score)"
    }
    
    private func getScore(cells:[[Cell]],pos:Pos,stone:Cell.Stone){
        var dummyCells = cells
        var turningStones = getTurningStones(cells: cells, pos: pos, stone: stone)
        turningStones.append(pos)
        for turnPos in turningStones{
            dummyCells[turnPos.x][turnPos.y] = stone.cell
        }
        
        
        //change turn
        
        
        let deployablePositions = checkAllCellsAndGetDeployablePositions(cells: dummyCells) { pos, cell in
            dummyCells[pos.x][pos.y] = cell
        }
        var myOppPos:[Pos] = []
        switch stone{
        case .black:
            myOppPos = deployablePositions.white
        case .white:
            myOppPos = deployablePositions.black
        }
        var score:Int = 3 * refPoints[pos.x][pos.y]
        for oppPos in myOppPos{
            score -= refPoints[oppPos.x][oppPos.y]
        }
        score -= myOppPos.count * 5
        self.scores[pos.x][pos.y] = score
        
        
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
            
            getScore(cells: dummyCells, pos: myPos, stone: myStone)
        }
        
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
