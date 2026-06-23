import Foundation

struct TimeLog: Identifiable, Codable {
    var id: UUID = UUID()
    let projectName: String
    let startTime: Date
    let endTime: Date
    let notes: String?
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}
