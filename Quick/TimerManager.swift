import Foundation

class TimerManager: ObservableObject {
    @Published var displayTime = "00:00"
    @Published var isRunning = false

    private var timer: Timer?
    private var seconds = 0

    func toggle() {
        if isRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.seconds += 1
                self.updateDisplay()
            }
        }
        isRunning.toggle()
    }

    func reset() {
        timer?.invalidate()
        seconds = 0
        updateDisplay()
        isRunning = false
    }

    private func updateDisplay() {
        let min = seconds / 60
        let sec = seconds % 60
        displayTime = String(format: "%02d:%02d", min, sec)
    }
}
