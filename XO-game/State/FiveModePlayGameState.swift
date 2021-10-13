//
//  FiveModePlayGameState.swift
//  XO-game
//
//  Created by Denis Kazarin on 13.10.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class FiveModePlayGameState: GameState {
    
    private weak var gameViewController: GameViewController?
    private weak var gameBoard: Gameboard?
    private weak var gameBoardView: GameboardView?
    private var player: Player = .first
    private var timer: Timer?
    
    var completionHandler: () -> Void
    var isMoveCompleted: Bool = false
    
    init(gameViewController: GameViewController, gameBoard: Gameboard, gameBoardView: GameboardView, completionHandler: @escaping () -> Void) {
        self.gameViewController = gameViewController
        self.gameBoard = gameBoard
        self.gameBoardView = gameBoardView
        self.completionHandler = completionHandler
    }
    
    @objc func performMove() {
        if GameSessionSingletone.shared.firstPlayerFiveModeMoves.count > 0 || GameSessionSingletone.shared.secondPlayerFiveModeMoves.count > 0 {
            var move: FiveModePlayerMove?
            
            if player == .first {
                move = GameSessionSingletone.shared.firstPlayerFiveModeMoves.removeFirst()
                gameViewController?.firstPlayerTurnLabel.isHidden = false
                gameViewController?.secondPlayerTurnLabel.isHidden = true
                
            } else {
                move = GameSessionSingletone.shared.secondPlayerFiveModeMoves.removeFirst()
                gameViewController?.firstPlayerTurnLabel.isHidden = true
                gameViewController?.secondPlayerTurnLabel.isHidden = false
            }
            
            if let move = move {
                addMark(at: move.movePosition)
                player = player.next
            }
            
        } else {
            timer?.invalidate()
            completionHandler()
        }
    }
    
    func begin() {
        timer = Timer.scheduledTimer(timeInterval: 0.75,
                                     target: self,
                                     selector: #selector(performMove),
                                     userInfo: nil, repeats: true)
    }
    
    func addMark(at position: GameboardPosition) {
        guard let gameBoardView = gameBoardView else { return }
        
        gameBoard?.setPlayer(player, at: position)
        
        if !gameBoardView.canPlaceMarkView(at: position) {
            gameBoardView.removeMarkView(at: position)
        }
        
        gameBoardView.placeMarkView(player.markViewPrototype.copy(), at: position)
    }
}

