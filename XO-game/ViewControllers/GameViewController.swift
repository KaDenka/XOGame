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
       
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            if self.currentState.isMoveCompleted {
                self.counter += 1
                self.setNextState()
            }
        }
    }
    
    private func setFirstState() {
        let player = Player.first
        currentState = PlayerState(player: player,
                                   gameViewController: self,
                                   gameBoard: gameBoard,
                                   gameBoardView: gameboardView,
                                   markViewPrototype: player.markViewPrototype)
    }
    
    private func setNextState() {
        
        if gameOverChecking() { return }
        
        let playerInputState = currentState as? PlayerState
        let player = playerInputState?.player.next
        
        if player == .computer {
            delay(seconds: 0.5) { [self] in
                currentState = ComputerState(player: player!,
                                            gameViewController: self,
                                            gameBoard: gameBoard,
                                            gameBoardView: gameboardView,
                                            markViewPrototype: player!.markViewPrototype)
                counter += 1
                if gameOverChecking() {return}
                setFirstState()
                return
            }
        }
        
        currentState = PlayerState(player: player!,
                                   gameViewController: self,
                                   gameBoard: gameBoard,
                                   gameBoardView: gameboardView,
                                   markViewPrototype: player!.markViewPrototype)
        
    }
    
    
    private func gameOverChecking() -> Bool {
        if let winner = referee.determineWinner() {
            Log(action: .gameFinished(winner: winner))
            currentState = GameOverState(winner: winner, gameViewController: self)
            return true
        }
        
        if counter >= 9 {
            Log(action: .gameFinished(winner: nil))
            currentState = GameOverState(winner: nil, gameViewController: self)
            return true
        }
        
        return false
    }
    
    private func delay(seconds: Double, completion: @escaping ()->()) {
        let timeInterval = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: timeInterval, execute: completion)
    }
    
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        gameModeSwitcher.isHidden = true
        gameboardView.isHidden = false
        gameboardView.clear()
        gameBoard.clear()
        counter = 0
        GameSessionSingletone.shared.gameMode = gameMode
        setFirstState()
        startGameButton.isHidden = true
        restartButton.isHidden = false
        if gameMode == .vsComputerGame {
            secondPlayerTurnLabel.text = "Computer"
        } else { secondPlayerTurnLabel.text = "2nd player"}
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        Log(action: .restartGame)
        
        gameboardView.clear()
        gameBoard.clear()
        setFirstState()
        counter = 0
    }
    
}

