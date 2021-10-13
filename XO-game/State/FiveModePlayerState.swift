//
//  FiveModePlayerState.swift
//  XO-game
//
//  Created by Denis Kazarin on 13.10.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class FiveModePlayerState: GameState {
    public let player: Player
    public let markViewPrototype: MarkView
    private weak var gameViewController: GameViewController?
    private weak var gameBoard: Gameboard?
    private weak var gameBoardView: GameboardView?
    
    var counter = 0
    var isMoveCompleted: Bool = false

    init(player: Player, gameViewController: GameViewController,
         gameBoard: Gameboard, gameBoardView: GameboardView, markViewPrototype: MarkView) {
        self.player = player
        self.gameViewController = gameViewController
        self.gameBoard = gameBoard
        self.gameBoardView = gameBoardView
        self.markViewPrototype = markViewPrototype
    }

    func begin() {
        switch player {
        case .first:
            gameViewController?.firstPlayerTurnLabel.isHidden = false
            gameViewController?.secondPlayerTurnLabel.isHidden = true
        case .second, .computer:
            gameViewController?.firstPlayerTurnLabel.isHidden = true
            gameViewController?.secondPlayerTurnLabel.isHidden = false
        }

        gameViewController?.winnerLabel.isHidden = true
    }

    func addMark(at position: GameboardPosition) {
        Log(action: .playerSetMark(player: player, position: position))

        guard let gameBoardView = gameBoardView,
              gameBoardView.canPlaceMarkView(at: position) else {
            return
        }

        gameBoard?.setPlayer(player, at: position)
        gameBoardView.placeMarkView(markViewPrototype.copy(), at: position)
        
        if player == .first {
            GameSessionSingletone.shared.firstPlayerFiveModeMoves.append(FiveModePlayerMove(player: .first, movePosition: position))
        } else {
            GameSessionSingletone.shared.secondPlayerFiveModeMoves.append(FiveModePlayerMove(player: .second, movePosition: position))
        }
        
        counter += 1
        if counter >= 5 { isMoveCompleted = true }
    }
}
