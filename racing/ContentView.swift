//
//  ContentView.swift
//  racing
//
//  Created by frankie.gg on 12/23/24.
//

import SwiftUI

struct CustomButton: View {
    var title: String
    var action: () -> Void
    var backgroundColor: Color
    var width: CGFloat? = nil // 고정 너비를 선택적으로 설정
    var height: CGFloat? = nil // 고정 높이를 선택적으로 설정
    var disabled: Bool = false
    var tooltipText: String? = nil
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .padding(.horizontal, 20) // 가로 패딩 추가
                .padding(.vertical, 10)   // 세로 패딩 추가
                .frame(maxWidth: width ?? .infinity, maxHeight: height ?? .infinity) // 유연한 프레임
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle()) // 기본 버튼 스타일 제거
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1.0)  // 비활성화 상태 시 반투명 처리
        .help(tooltipText ?? "") // tooltip 대체
    }
}

struct ContentView: View {
    @EnvironmentObject var optionsViewModel: OptionsViewModel // ViewModel 사용

    @State private var transparency: Double = 0.9 // 초기 투명도 값
    @StateObject private var viewModel = StopwatchViewModel()
    private let keyboardMonitor = GlobalKeyboardMonitor()
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showStopConfirmation: Bool = false
    
    var body: some View {
        VStack(spacing: 20) { // VStack 간격 설정ㅌ
            // 투명도 조절 슬라이더
            HStack {
                Text("Transparency: \(String(format: "%.2f", transparency))")
                    .frame(width: 100, alignment: .leading)
                
                Slider(
                    value: Binding(
                        get: {
                            self.transparency
                        },
                        set: { newValue in
                            self.transparency = newValue
                            setWindowTransparency(newValue)
                        }
                    ),
                    in: 0.2...1.0
                )
                .tint(.blue)
            }
            .padding([.leading, .trailing])
            // .onReceive(Just(transparency)) { newValue in
            //     setWindowTransparency(newValue)
            // } // 제거
            
            // 타이머 표시
            Text(viewModel.formattedTime)
                .font(.largeTitle)
                .padding()
            
            // 버튼들: Start/Pause, Stop
            HStack(spacing: 20) {
                // Start / Pause 버튼
                CustomButton(
                    title: viewModel.isRunning ? "Pause" : "Start",
                    action: {
                        viewModel.toggleStartStop()
                    },
                    backgroundColor: .blue,
                    height: 50
                )
                .frame(maxWidth: .infinity) // 버튼이 남은 공간을 채우도록 설정
                
                // Stop 버튼
                CustomButton(
                    title: "Stop",
                    action: {
                        showStopConfirmation = true
                    },
                    backgroundColor: .red,
                    height: 50
                )
                .frame(maxWidth: .infinity)
                .alert(isPresented: $showStopConfirmation) {
                    Alert(
                        title: Text("Stop Timer"),
                        message: Text("Are you sure you want to stop the timer?"),
                        primaryButton: .destructive(Text("Stop")) {
                            viewModel.stopTimer()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding([.leading, .trailing])
            
            
            // 랩 타임 리스트
            VStack(alignment: .leading) {
                // 리스트 헤더
                HStack {
                    Text("Lap")
                        .font(.headline)
                        .frame(width: 50, alignment: .leading)
                    Spacer()
                    Text("Start")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Text("Duration")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                }
                .padding(.horizontal)
                
                // 리스트 항목
                List(viewModel.lapTimes) { lap in
                    HStack {
                        Text("Lap \(lap.lapNumber)")
                            .frame(width: 50, alignment: .leading)
                        Spacer()
                        
                        Text("\(lap.startTime)")
                            .frame(width: 100, alignment: .leading)
                        Spacer()
                        Text("\(lap.lapTime)")
                            .frame(width: 100, alignment: .leading)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle()) // 리스트 스타일 설정 (선택 사항)
                .frame(maxHeight: 200) // 리스트의 최대 높이 설정 (선택 사항)
            }
            .padding([.leading, .trailing])
            
            // 마지막 랩 삭제 버튼
            CustomButton(
                title: "Delete Last Lap",
                action: {
                    showDeleteConfirmation = true
                },
                backgroundColor: .gray,
                height: 30,
                disabled: viewModel.lapTimes.isEmpty,
                tooltipText: viewModel.lapTimes.isEmpty ? "No laps to delete" : "Delete the last lap"
            )
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing])
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Last Lap"),
                    message: Text("Are you sure you want to delete the last lap?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteLastLap()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding()
        .frame(minWidth: 350, maxWidth: 500, minHeight: 400, maxHeight: 600) // 전체 뷰의 최소 및 최대 크기 설정
        .onAppear {
            startGlobalKeyboardMonitoring()
        }
    }
    // MARK: - Private Methods
    
    private func startGlobalKeyboardMonitoring() {
        keyboardMonitor.startMonitoring { event in
            switch event.keyCode {
            case 1:
                if event.modifierFlags.contains(.command) &&
                    event.modifierFlags.contains(.shift) {
                    DispatchQueue.main.async {
                        viewModel.toggleStartStop()
                    }
                }
                
            default:
                break
            }
        }
    }
    
    private func setWindowTransparency(_ alpha: Double) {
        if let window = NSApplication.shared.windows.first {
            window.alphaValue = alpha
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
