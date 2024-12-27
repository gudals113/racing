import Foundation

struct Lap: Identifiable {
    let id = UUID()
    let lapNumber: Int
    let startTime: String       // 랩 시작 시각 (문자열)
    let lapTime: String         // 랩 소요 시간 (HH:mm:ss)
    let lapDuration: TimeInterval // 랩 소요 시간 (초 단위)
}

class StopwatchViewModel: ObservableObject {
    @Published var formattedTime: String = "00:00:00"  // 전체 누적 시간 표시
    @Published var isRunning: Bool = false
    @Published var lapTimes: [Lap] = []

    private var timer: Timer?
    private var lapStartTime: Date?                  // 현재 랩이 시작된 시점
    private var totalElapsedTime: TimeInterval = 0   // 전체 누적 시간

    /// Start/Pause 토글
    func toggleStartStop() {
        if isRunning {
            pauseLap()   // 현재 랩 일시정지 및 기록
        } else {
            startLap()   // 새로운 랩 시작
        }
    }

    /// 새 랩 시작
    func startLap() {
        guard !isRunning else { return }
        lapStartTime = Date()                 // 새 랩 시작 시각 기록
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTime()
        }
        isRunning = true
    }

    /// 현재 랩 일시정지 및 기록
    func pauseLap() {
        guard isRunning, let lapStartTime = lapStartTime else { return }

        // 타이머 중단
        timer?.invalidate()
        isRunning = false

        // 현재 시각 (랩 종료 시점)
        let lapEndTime = Date()
        // 랩 시간 계산 (종료 시점 - 시작 시점)
        let lapDuration = lapEndTime.timeIntervalSince(lapStartTime)

        // 전체 누적 시간에 현재 랩 시간 추가
        totalElapsedTime += lapDuration

        // 랩 시간 문자열로 변환
        let lapTimeString = formatTime(lapDuration)
        // 랩 시작 시각 문자열로 변환
        let startTimeString = DateFormatter.localizedString(
            from: lapStartTime,
            dateStyle: .none,
            timeStyle: .medium
        )

        // Lap 객체 생성 및 배열에 추가
        let newLap = Lap(
            lapNumber: lapTimes.count + 1,
            startTime: startTimeString,
            lapTime: lapTimeString,
            lapDuration: lapDuration
        )
        lapTimes.append(newLap)

        // 전체 누적 시간을 문자열로 변환하여 표시
        formattedTime = formatTime(totalElapsedTime)

        // 다음 랩을 위해 lapStartTime 초기화
        self.lapStartTime = nil
    }

    /// 마지막 랩 삭제
    func deleteLastLap() {
        guard !lapTimes.isEmpty else { return } // 배열이 비어있지 않은지 확인

        // 마지막 랩을 제거하고 그 시간을 전체 누적 시간에서 차감
        let lastLap = lapTimes.removeLast()
        totalElapsedTime -= lastLap.lapDuration

        // 전체 누적 시간이 음수가 되지 않도록 방어
        if totalElapsedTime < 0 {
            totalElapsedTime = 0
        }

        // 전체 누적 시간을 문자열로 변환하여 표시
        formattedTime = formatTime(totalElapsedTime)
    }

    /// 타이머 완전 정지 (모든 랩 정보 초기화)
    func stopTimer() {
        timer?.invalidate()
        lapStartTime = nil
        totalElapsedTime = 0
        formattedTime = "00:00:00"
        lapTimes.removeAll()
        isRunning = false
    }

    /// 1초마다 호출되어 전체 누적 시간 업데이트
    func updateTime() {
        guard let lapStartTime = lapStartTime else { return }
        let currentLapTime = Date().timeIntervalSince(lapStartTime)
        let currentTotalTime = totalElapsedTime + currentLapTime
        formattedTime = formatTime(currentTotalTime)
    }

    /// TimeInterval을 "HH:mm:ss" 형식의 문자열로 변환
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
