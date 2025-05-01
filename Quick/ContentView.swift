import SwiftUI
import AppKit

struct ContentView: View {
    @State private var tasks: String = ""
    @State private var timeRemaining: Int = 1500
    @State private var customTimeInput: String = "25:00"
    @State private var timerRunning = false
    @State private var timer: Timer?
    @State private var lastValidInput: String = "25:00"

    var body: some View {
        VStack(spacing: 10) {
            // Tasks Input – expands vertically only if needed
            TextEditor(text: $tasks)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundColor(.black)
                .padding(6)
                .frame(minHeight: 20, maxHeight: .infinity)
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(8)
                .scrollContentBackground(.hidden)

            Spacer(minLength: 10)

            // Editable Timer Input (when paused)
            TextField("", text: $customTimeInput)
                .disabled(timerRunning)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .onSubmit {
                    if updateTimeFromInput() {
                        lastValidInput = customTimeInput
                    } else {
                        customTimeInput = lastValidInput
                    }
                }
                .padding(.bottom, 5)
                .background(Color.clear)
                .textFieldStyle(PlainTextFieldStyle())
                .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.clear, lineWidth: 0))

            // Start/Pause toggle text
            Text(timerRunning ? "Pause" : "Start")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .onTapGesture {
                    if timerRunning {
                        timer?.invalidate()
                    } else {
                        if updateTimeFromInput() {
                            lastValidInput = customTimeInput
                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                    customTimeInput = formatTime(seconds: timeRemaining)
                                } else {
                                    timer?.invalidate()
                                    timerRunning = false
                                    playSound()
                                }
                            }
                        } else {
                            customTimeInput = lastValidInput
                        }
                    }
                    timerRunning.toggle()
                }
                .padding(.bottom, 5)
        }
        .padding()
        .frame(minWidth: 80, minHeight: 50)
        .background(Color(red: 1.0, green: 0.98, blue: 0.7)) // Post-it yellow
    }

    func formatTime(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    func updateTimeFromInput() -> Bool {
        let input = customTimeInput.trimmingCharacters(in: .whitespaces)

        if input.contains(":") {
            let parts = input.split(separator: ":")
            guard parts.count == 2,
                  let min = Int(parts[0]),
                  let sec = Int(parts[1]),
                  sec >= 0 && sec < 60 else {
                return false
            }
            timeRemaining = min * 60 + sec
            return true
        } else if input.contains(".") {
            guard let decimal = Double(input),
                  decimal >= 0,
                  (decimal * 100).truncatingRemainder(dividingBy: 1) == 0 else {
                return false
            }
            let minutes = Int(decimal)
            let seconds = Int((decimal - Double(minutes)) * 60)
            timeRemaining = minutes * 60 + seconds
            customTimeInput = formatTime(seconds: timeRemaining)
            return true
        } else if let min = Int(input) {
            timeRemaining = min * 60
            customTimeInput = formatTime(seconds: timeRemaining)
            return true
        }

        return false
    }

    func playSound() {
        NSSound(named: "Glass")?.play()
    }
}

#Preview {
    ContentView()
}
