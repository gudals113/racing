//
//  racingApp.swift
//  racing
//
//  Created by frankie.gg on 12/23/24.
//

import SwiftUI

@main
struct racingApp: App {
    @StateObject private var optionsViewModel = OptionsViewModel() // ViewModel 생성

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(optionsViewModel)
                .frame(minWidth: 350, minHeight: 400)
        }
        .commands {
                   OptionsMenuCommands(optionsViewModel: optionsViewModel) // ViewModel 전달
               }
    }
}

class OptionsViewModel: ObservableObject {
    @Published var isAlwaysOnTop: Bool = false {
        didSet {
            updateWindowLevel()
        }
    }
    
    private func updateWindowLevel() {
        guard let window = NSApplication.shared.mainWindow else { return }
        window.level = isAlwaysOnTop ? .floating : .normal
    }
}
