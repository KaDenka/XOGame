//
//  LogFunc.swift
//  XO-game
//
//  Created by Veaceslav Chirita on 27.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

public func Log(action: LogAction) {
    let command = LogCommand(action: action)
    LogInvoker.shared.addLogCommand(command: command)
}
