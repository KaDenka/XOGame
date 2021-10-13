//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    // MARK: - Размещение элементов контроллера
    
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
    
// MARK: - Добавление необходимых переменных
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
    // MARK: - Отработка действующей позиции
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            if self.currentState.isMoveCompleted {
                
                if GameSessionSingletone.shared.gameMode == .fiveOnFiveGame {
                    self.delay(seconds: 0.5) {
                        self.gameboardView.clear()
                        self.gameBoard.clear()
                        self.setNextState()
                    }
                } else {
                    self.counter += 1
                    self.setNextState()
                }
            }
        }
    }
// MARK: - Первичное состояние игрока
    private func setFirstState() {
        let player = Player.first
        
        if GameSessionSingletone.shared.gameMode == .fiveOnFiveGame {
            currentState = FiveModePlayerState(player: player,
                                               gameViewController: self,
                                               gameBoard: gameBoard,
                                               gameBoardView: gameboardView,
                                               markViewPrototype: player.markViewPrototype)
        } else { currentState = PlayerState(player: player,
                                            gameViewController: self,
                                            gameBoard: gameBoard,
                                            gameBoardView: gameboardView,
                                            markViewPrototype: player.markViewPrototype)
        }
    }
// MARK: - Следующее состояние игрока
    private func setNextState() {
        
        // Завершение игры в режиме пять-на-пять
        if GameSessionSingletone.shared.gameMode == .fiveOnFiveGame && gameCompletionChecking() {
            currentState = FiveModePlayGameState(gameViewController: self,
                                                 gameBoard: gameBoard,
                                                 gameBoardView: gameboardView) { [self] in
                
                if let winner = referee.determineWinner() {
                    Log(action: .gameFinished(winner: winner))
                    currentState = GameOverState(winner: winner, gameViewController: self)
                } else {
                    Log(action: .gameFinished(winner: nil))
                    currentState = GameOverState(winner: nil, gameViewController: self)
                }
            }
            return
        }
        
        // Завершение игры в режимах двух игроков и против компьютера
        if GameSessionSingletone.shared.gameMode != .fiveOnFiveGame && gameOverChecking() { return }
        
        
        // Формирование состояния игрока
        let playerInputState = currentState as? PlayerState
        let player = playerInputState?.player.next
        
        
        // Отработка хода в режиме пять-на-пять или хода игрока в режиме двух игроков
        if GameSessionSingletone.shared.gameMode == .fiveOnFiveGame, let playerInputState = currentState as? FiveModePlayerState {
            let player = playerInputState.player.next
            currentState = FiveModePlayerState(player: player,
                                               gameViewController: self,
                                               gameBoard: gameBoard,
                                               gameBoardView: gameboardView,
                                               markViewPrototype: player.markViewPrototype)
        } else {
            currentState = PlayerState(player: player!,
                                       gameViewController: self,
                                       gameBoard: gameBoard,
                                       gameBoardView: gameboardView,
                                       markViewPrototype: player!.markViewPrototype)
        }
        
        // Отработка хода компьютера
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
    
    private func gameCompletionChecking() -> Bool {
        return GameSessionSingletone.shared.firstPlayerFiveModeMoves.count > 0 && GameSessionSingletone.shared.secondPlayerFiveModeMoves.count > 0
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

