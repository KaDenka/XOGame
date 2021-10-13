//
//  LogAction.swift
//  XO-game
//
//  Created by Veaceslav Chirita on 27.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

public enum LogAction {
    case playerSetMark(player: Player, position: GameboardPosition)
    case gameFinished(winner: Player?)
    case restartGame
}
