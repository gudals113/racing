import SwiftUI

struct OptionsMenuCommands: Commands {
    @ObservedObject var optionsViewModel: OptionsViewModel
    
    var body: some Commands {
        CommandGroup(after: .appInfo) { // "About" 메뉴 뒤에 추가
            Divider()
            Button(optionsViewModel.isAlwaysOnTop ? "Disable Always on Top" : "Enable Always on Top") {
                optionsViewModel.isAlwaysOnTop.toggle()
            }
        }
    }
}

