import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimeTrackerViewModel()
    @State private var notesText: String = ""
    
    var body: some View {
        TabView {
            // Timer Tab
            NavigationStack {
                VStack(spacing: 25) {
                    // Project Selector
                    Picker("Project", selection: $viewModel.selectedProject) {
                        ForEach(viewModel.availableProjects, id: \.self) { project in
                            Text(project).tag(project)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .disabled(viewModel.isRunning)
                    
                    Spacer()
                    
                    // Circular Timer Display
                    ZStack {
                        Circle()
                            .stroke(Color.indigo.opacity(0.15), lineWidth: 15)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.isRunning ? CGFloat((Int(viewModel.currentDuration) % 60)) / 60.0 : 0.0)
                            .stroke(
                                LinearGradient(
                                    colors: [.indigo, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1.0), value: viewModel.currentDuration)
                        
                        VStack(spacing: 8) {
                            Text(timeString(from: viewModel.currentDuration))
                                .font(.system(size: 42, weight: .bold, design: .monospaced))
                                .contentTransition(.numericText())
                            
                            Text(viewModel.isRunning ? "Tracking..." : "Idle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(1.5)
                        }
                    }
                    
                    Spacer()
                    
                    // Notes Input
                    if viewModel.isRunning {
                        TextField("What are you working on?", text: $notesText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    // Start/Stop Action Buttons
                    Button(action: {
                        withAnimation {
                            if viewModel.isRunning {
                                viewModel.stopTimer(notes: notesText.isEmpty ? nil : notesText)
                                notesText = ""
                            } else {
                                viewModel.startTimer()
                            }
                        }
                    }) {
                        Text(viewModel.isRunning ? "Stop Session" : "Start Tracking")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.isRunning ?
                                    AnyShapeStyle(Color.red) :
                                    AnyShapeStyle(
                                        LinearGradient(
                                            colors: [.indigo, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .cornerRadius(12)
                            .shadow(color: (viewModel.isRunning ? Color.red : Color.indigo).opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .navigationTitle("Time Tracker")
                .background(Color(.systemGroupedBackground))
            }
            .tabItem {
                Label("Timer", systemImage: "play.circle.fill")
            }
            
            // History Tab
            NavigationStack {
                List {
                    // Summary Section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Time Tracked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                Text(timeString(from: viewModel.logs.reduce(0) { $0 + $1.duration }))
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Image(systemName: "hourglass.badge.plus")
                                .font(.title)
                                .foregroundColor(.indigo)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Logs List Section
                    Section("Log History") {
                        if viewModel.logs.isEmpty {
                            Text("No logged sessions yet.")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(viewModel.logs) { log in
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(log.projectName)
                                            .font(.headline)
                                            .foregroundColor(.indigo)
                                        if let notes = log.notes {
                                            Text(notes)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(log.startTime, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(timeString(from: log.duration))
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: viewModel.deleteLog)
                        }
                    }
                }
                .navigationTitle("History")
                .toolbar {
                    EditButton()
                }
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
        }
        .accentColor(.indigo)
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
