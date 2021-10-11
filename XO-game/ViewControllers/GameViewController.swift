//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet var gameboardView: GameboardView! {
        didSet {
            gameboardView.isHidden = true
        }
    }
    @IBOutlet var firstPlayerTurnLabel: UILabel! {
        didSet {
            firstPlayerTurnLabel.isHidden = true
        }
    }
    @IBOutlet var secondPlayerTurnLabel: UILabel! {
        didSet {
            secondPlayerTurnLabel.isHidden = true
        }
    }
    @IBOutlet var winnerLabel: UILabel! {
        didSet {
            winnerLabel.isHidden = true
        }
    }
    @IBOutlet var restartButton: UIButton! {
        didSet {
            restartButton.isHidden = true
        }
    }
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gameModeSwitcher: UISegmentedControl!
    
    private let gameBoard = Gameboard()
    private var counter = 0
    private var gameMode: GameMode {
        switch self.gameModeSwitcher.selectedSegmentIndex {
        case 0: return .twoPlayersGame
        case 1: return .vsComputerGame
        case 2: return .fiveOnFiveGame
        default: return .twoPlayersGame
        }
    }
    
    private lazy var referee = Referee(gameboard: gameBoard)
    private var currentState: GameState! {
        didSet {
            currentState.begin()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // setFirstState()
        
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            
            self.currentState.addMark(at: position)
            if self.currentState.isMoveCompleted {
                self.counter += 1
                self.setNextState()
            }
            
            //            self.gameboardView.placeMarkView(XView(), at: position)
        }
    }
    
    private func setFirstState() {
        if gameMode == .vsComputerGame {
            secondPlayerTurnLabel.text = "Computer"
        } else { secondPlayerTurnLabel.text = "2nd player"}
        gameboardView.isHidden = false
        let player = Player.first
        currentState = PlayerState(player: player,
                                   gameViewController: self,
                                   gameBoard: gameBoard,
                                   gameBoardView: gameboardView,
                                   markViewPrototype: player.markViewPrototype)
    }
    
    private func setNextState() {
        if let winner = referee.determineWinner() {
            Log(action: .gameFinished(winner: winner))
            currentState = GameOverState(winner: winner, gameViewController: self)
            
            return
        }
        
        if counter >= 9 {
            Log(action: .gameFinished(winner: nil))
            currentState = GameOverState(winner: nil, gameViewController: self)
            return
        }
        
        if let playerInputState = currentState as? PlayerState {
            let player = playerInputState.player.next
            currentState = PlayerState(player: player,
                                       gameViewController: self,
                                       gameBoard: gameBoard,
                                       gameBoardView: gameboardView, markViewPrototype: player.markViewPrototype)
        }
    }
    
    
    
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        gameModeSwitcher.isHidden = true
        gameboardView.clear()
        gameBoard.clear()
        counter = 0
        setFirstState()
        startGameButton.isHidden = true
        restartButton.isHidden = false
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        Log(action: .restartGame)
        
        gameboardView.clear()
        gameBoard.clear()
        setFirstState()
        counter = 0
    }
}

