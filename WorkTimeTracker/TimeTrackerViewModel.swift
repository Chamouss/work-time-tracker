import Foundation
import Combine

class TimeTrackerViewModel: ObservableObject {
    @Published var logs: [TimeLog] = [] {
        didSet {
            saveLogs()
        }
    }
    
    @Published var isRunning = false
    @Published var startTime: Date? = nil
    @Published var currentDuration: TimeInterval = 0
    @Published var selectedProject = "General"
    
    private var timer: AnyCancellable?
    private let logsKey = "work_time_tracker_logs"
    
    let availableProjects = ["General", "Development", "Design", "Marketing", "Learning", "Meetings"]
    
    init() {
        loadLogs()
        // If app crashed or quit while timer was running, let's restore state if needed, or default to idle.
    }
    
    func startTimer() {
        guard !isRunning else { return }
        startTime = Date()
        isRunning = true
        currentDuration = 0
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let start = self.startTime else { return }
                self.currentDuration = Date().timeIntervalSince(start)
            }
    }
    
    func stopTimer(notes: String? = nil) {
        guard isRunning, let start = startTime else { return }
        
        let newLog = TimeLog(
            projectName: selectedProject,
            startTime: start,
            endTime: Date(),
            notes: notes
        )
        
        // Reset state
        timer?.cancel()
        timer = nil
        isRunning = false
        startTime = nil
        currentDuration = 0
        
        // Add log
        logs.insert(newLog, at: 0)
    }
    
    func deleteLog(at offsets: IndexSet) {
        logs.remove(atOffsets: offsets)
    }
    
    private func saveLogs() {
        do {
            let data = try JSONEncoder().encode(logs)
            UserDefaults.standard.set(data, forKey: logsKey)
        } catch {
            print("Failed to save logs: \(error.localizedDescription)")
        }
    }
    
    private func loadLogs() {
        guard let data = UserDefaults.standard.data(forKey: logsKey) else { return }
        do {
            let decodedLogs = try JSONDecoder().decode([TimeLog].self, from: data)
            self.logs = decodedLogs
        } catch {
            print("Failed to load logs: \(error.localizedDescription)")
        }
    }
}
