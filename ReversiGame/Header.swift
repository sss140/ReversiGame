//
//  Header.swift
//  ReversiGame
//
//  Created by 佐藤一成 on 2021/12/21.
//

import SwiftUI

struct Header: View {
    @State var player:Player
    @Binding var bool:Bool
    var body: some View {
        VStack{
        Text("\(player.rawValue)")
            Toggle("", isOn: $bool)
                .labelsHidden()
            Text(bool ? "C O M":"HUMAN")
        }
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header(player: .black, bool: .constant(false))
    }
}
