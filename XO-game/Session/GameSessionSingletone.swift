//
//  GameSessionSingletone.swift
//  XO-game
//
//  Created by Denis Kazarin on 12.10.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

final class GameSessionSingletone {
    static let shared = GameSessionSingletone()
    private init() {}
    var gameMode: GameMode?
}
