//
//  ContentView.swift
//  ReversiGame
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

class ReversiGame:ObservableObject{
    typealias Pos = (x:Int,y:Int)
    
    // when game is over then false
    var isIngame:Bool = false
    //player's stone
    var player:Cell.Stone = .black
    // for animation purpose
    @Published var sequenceCells:[Pos] = []
    // all cells information
    @Published var cells:[[Cell]] = []
    private func setCell(pos:Pos,cell:Cell){
        self.cells[pos.x][pos.y] = cell
    }
    private func getCell(pos:Pos)->Cell{
        self.cells[pos.x][pos.y]
    }
    
    //number of stone it is not compulsory for the program
    @Published var stoneCounts:(black:Int,white:Int) = (0,0)
    private func countStones(){
        stoneCounts = (0,0)
        for x in 0..<8{
            for y in 0..<8{
                let pos:Pos = (x,y)
                stoneCounts.black += (getCell(pos: pos) == .stone(stone: .black)) ? 1:0
                stoneCounts.white += (getCell(pos: pos) == .stone(stone: .white)) ? 1:0
            }
        }
    }
    // message string.
    @Published var message:String = ""
    private func makeMesage(){
        if isIngame{
            message = "\(player == .black ? "Black":"White")'s turn\n"
        }else{
            if stoneCounts.black == stoneCounts.white{
                message = "DRAW\n"
            }else{
                message = "\(stoneCounts.black>stoneCounts.white ? "Black":"White") Won\n"
            }
        }
        message += "Black:\(stoneCounts.black) - White:\(stoneCounts.white)"
    }
    
    init(){
        startUp()
    }
    
    func startUp(){
        player = .black
        sequenceCells = []
        isIngame = true
        cells.removeAll()
        let oneRow:[Cell] = [Cell](repeating: .empty(deployable: .none), count: 8)
        cells = [[Cell]](repeating: oneRow, count: 8)
        setCell(pos:(x: 3, y: 3), cell: .stone(stone: .black))
        setCell(pos:(x: 4, y: 4), cell: .stone(stone: .black))
        setCell(pos:(x: 3, y: 4), cell: .stone(stone: .white))
        setCell(pos:(x: 4, y: 3), cell: .stone(stone: .white))
        _ = checkAllCells()
        countStones()
        makeMesage()
    }
    // turn stones change turn
    func progressGame(pos:Pos){
        func canChangePlayer(cell:Cell)->Bool{
            switch cell {
            case .stone(_):
                return false
            case .empty(let deployable):
                switch deployable {
                case .both:return true
                case .black:return (player == .black)
                case .white:return (player == .white)
                case .none:return false
                }
            }
        }
        
        guard sequenceCells.count == 0 else{return}
        let cell = getCell(pos: pos)
        
        guard canChangePlayer(cell: cell) else{return}
        let reverseCells:[Pos] = [pos] + checkDeployable(pos: pos, stone: player)
        sequenceCells = reverseCells
    }
    // called from ContentView constantly
    func removeFirstPos(){
        if sequenceCells.count>0{
            let pos = sequenceCells[0]
            setCell(pos: pos, cell: player.cell)
            sequenceCells.remove(at: 0)
            
            if sequenceCells.count == 0{
                changePlayerOrEndGame()
            }
            countStones()
            makeMesage()
        }
    }
    // change player check whethr game is over or not
    private func changePlayerOrEndGame(){
        let reversibleCells = checkAllCells()
        switch(black:reversibleCells.black.count>0,white:reversibleCells.white.count>0){
        case (true,true):player = player.opposedPlayer
        case (true,false):player = .black
        case (false,true):player = .white
        case (false,false):isIngame = false
        }
    }

    // functions set cells array and return deployable cells for both
    private func checkAllCells()->(black:[Pos],white:[Pos]){
        var reversibleCells:(black:[Pos],white:[Pos]) = (black:[],white:[])
        for x in 0..<8{
            for y in 0..<8{
                let pos = (x:x,y:y)
                let cell = checkOneCell(pos:pos)
                setCell(pos:pos, cell: cell)
                switch cell{
                case .empty(deployable: .both):
                    reversibleCells.black.append(pos)
                    reversibleCells.white.append(pos)
                case .empty(deployable: .black):
                    reversibleCells.black.append(pos)
                case .empty(deployable: .white):
                    reversibleCells.white.append(pos)
                default:
                    _ = true
                }
            }
        }
        return reversibleCells
    }
    
    //check one cell both stones by using checkDeployable
    private func checkOneCell(pos: Pos)->Cell{
        let cell = getCell(pos: pos)
        switch cell{
        case .stone(stone: .black): return Cell.stone(stone: .black)
        case .stone(stone: .white): return Cell.stone(stone: .white)
        case .empty(_):
            let bools:[Bool] = Cell.Stone.allCases.map { stone in
                return (checkDeployable(pos: pos, stone: stone).count>0)
            }
            switch (black:bools[0],white:bools[1]){
            case (true,true):return Cell.empty(deployable: .both)
            case (true,false):return Cell.empty(deployable: .black)
            case (false,true):return Cell.empty(deployable: .white)
            case (false,false):return Cell.empty(deployable: .none)
            }
        }
    }
    
    //check one cell either black or white. called by checkOneCell
    private func checkDeployable(pos:Pos,stone:Cell.Stone)->[Pos]{
        func checkStone(pos: Pos,targetStone:Cell)->Bool{
            guard (0..<8).contains(pos.x) && (0..<8).contains(pos.y) else{
                return false
            }
            return getCell(pos: pos) == targetStone
        }
        
        var result:[Pos] = []
        guard !getCell(pos: pos).isStoneOn else{return result}
        for direction in Direction.allCases{
            var stones:[Pos] = []
            var nextPos = (x:pos.x + direction.axis.x,y:pos.y + direction.axis.y)
            while(checkStone(pos: nextPos, targetStone: stone.opposed)){
                stones.append(nextPos)
                nextPos = (x:nextPos.x + direction.axis.x,y:nextPos.y + direction.axis.y)
            }
            guard checkStone(pos: nextPos, targetStone: stone.cell) else{continue}
            result += stones
        }
        return result
    }
}

struct ContentView: View {
    @ObservedObject var reversi = ReversiGame()
    let length:CGFloat = 0.9 * UIScreen.main.bounds.width/CGFloat(8)
    var body: some View {
        VStack(spacing: 0.0) {
            ForEach(0..<8){ y in
                HStack(spacing: 0.0) {
                    ForEach(0..<8){ x in
                        ZStack{
                            Rectangle()
                                .fill(.green)
                                .frame(width:length, height: length)
                                .border(Color.black)
                            Circle()
                                .fill(self.reversi.cells[x][y].stoneColor)
                                .frame(width:length * 0.8, height: length * 0.8)
                            VStack{
                                Text("(\(x),\(y))")
                                    .foregroundColor(Color.red)
                            }.font(.subheadline)
                        }.onTapGesture {
                            self.reversi.progressGame(pos: (x:x,y:y))
                        }
                    }
                }
            }
        }.onReceive(Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()) { t in
            self.reversi.removeFirstPos()
        }
        .animation(Animation.linear(duration: 0.5))
        VStack{
            Text(self.reversi.message)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Text("RESET")
                .font(.largeTitle)
                .foregroundColor(.red)
                .onTapGesture {
                    self.reversi.startUp()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
