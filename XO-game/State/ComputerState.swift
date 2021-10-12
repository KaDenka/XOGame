//
//  ComputerState.swift
//  XO-game
//
//  Created by Denis Kazarin on 11.10.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class ComputerState: GameState {
    public let player: Player
    var isMoveCompleted: Bool = false
    private weak var gameViewController: GameViewController?
    private weak var gameBoard: Gameboard?
    private weak var gameBoardView: GameboardView?
    
    public let markViewPrototype: MarkView
    
    init(player: Player, gameViewController: GameViewController,
         gameBoard: Gameboard, gameBoardView: GameboardView, markViewPrototype: MarkView) {
        self.player = player
        self.gameViewController = gameViewController
        self.gameBoard = gameBoard
        self.gameBoardView = gameBoardView
        self.markViewPrototype = markViewPrototype
    }
    
    func begin() {

            gameViewController?.firstPlayerTurnLabel.isHidden = true
            gameViewController?.secondPlayerTurnLabel.isHidden = false
        
        if let position = computerMarkPosition() {
            addMark(at: position)
        }
        
        gameViewController?.winnerLabel.isHidden = true
       
    }
    
    private func computerMarkPosition() -> GameboardPosition? {
        var positions: [GameboardPosition] = []
        
        for col in 0...GameboardSize.columns - 1 {
            for row in 0...GameboardSize.rows - 1 {
                let position = GameboardPosition(column: col, row: row)
                if gameBoardView!.canPlaceMarkView(at: position) {
                    positions.append(position)
                }
            }
        }
        return positions.randomElement()
    }
    
    func addMark(at position: GameboardPosition) {
        Log(action: .playerSetMark(player: player, position: position))
        
        guard let gameBoardView = gameBoardView,
              gameBoardView.canPlaceMarkView(at: position) else {
                  return
              }
        gameBoard?.setPlayer(player, at: position)
        gameBoardView.placeMarkView(markViewPrototype.copy(), at: position)
        isMoveCompleted = true
    }
    
    
    
}
