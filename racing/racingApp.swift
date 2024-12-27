//
//  racingApp.swift
//  racing
//
//  Created by frankie.gg on 12/23/24.
//

import SwiftUI

@main
struct racingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 350, minHeight: 400)
                .onAppear {
                    addOptionsButtonToTitleBar()
                }
        }
    }
    
    private func addOptionsButtonToTitleBar() {
        // 현재 윈도우 가져오기
        if let window = NSApplication.shared.windows.first {
            let toolbar = NSToolbar(identifier: "ToolbarIdentifier")
            toolbar.delegate = ToolbarDelegate()
            toolbar.displayMode = .iconOnly
            window.toolbar = toolbar
            window.titleVisibility = .hidden
        }
    }
}

// 툴바 델리게이트 설정
class ToolbarDelegate: NSObject, NSToolbarDelegate {
    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        if itemIdentifier == .optionsButton {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Options"
            item.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Options")
            item.target = self
            item.action = #selector(showOptionsPopover)
            return item
        }
        return nil
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.optionsButton]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.optionsButton]
    }
    
    @objc private func showOptionsPopover() {
        let alert = NSAlert()
        alert.messageText = "Options"
        alert.informativeText = "You can configure app settings here."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// 커스텀 툴바 버튼의 Identifier 확장
extension NSToolbarItem.Identifier {
    static let optionsButton = NSToolbarItem.Identifier("OptionsButton")
}
