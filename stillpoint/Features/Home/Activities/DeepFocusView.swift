import SwiftUI
import UniformTypeIdentifiers

struct DeepFocusView: View {
    let onDismiss: () -> Void

    @State private var step: Step = .taskInput

    // Step 1 — Task input state
    @State private var taskDescription = ""
    @State private var attachedFiles: [AttachedFile] = []
    @State private var showFilePicker = false

    // Step 4 — Timer state
    @State private var totalSeconds = 20 * 60
    @State private var remainingSeconds = 20 * 60
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var currentTaskIndex = 0

    // Mock task plan returned by "backend"
    private var taskPlan: [FocusTask] {
        [
            FocusTask(title: "Break down the problem", minutes: 4),
            FocusTask(title: "Research and gather info", minutes: 5),
            FocusTask(title: "Draft initial approach", minutes: 6),
            FocusTask(title: "Review and refine", minutes: 5),
        ]
    }

    var body: some View {
        switch step {
        case .taskInput: taskInputView
        case .planReview: planReviewView
        case .soundCheck: soundCheckView
        case .timer: timerView
        case .finishCheck: finishCheckView
        case .complete:
            ActivityCompleteView(
                activityName: "Deep Focus",
                xpEarned: 60,
                onDone: onDismiss
            )
        }
    }

    // MARK: - Step 1: Task Input
    // Large text area for describing the task + multi-file upload (jpg/png/pdf/docx)

    private var taskInputView: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 24) {
                Spacer().frame(height: 72)

                VStack(spacing: 4) {
                    Text("DEEP FOCUS")
                        .font(.spActivityLabel)
                        .foregroundStyle(Color.spTextSecondary)
                        .tracking(0.832)

                    Text("What do you need\nto work on?")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                        .multilineTextAlignment(.center)
                }

                // Large text area for task description
                TextEditor(text: $taskDescription)
                    .font(.spBody)
                    .padding(16)
                    .frame(minHeight: 140)
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                    .cornerRadius(24)
                    .overlay(alignment: .topLeading) {
                        if taskDescription.isEmpty {
                            Text("Describe your task in detail — what do you want to accomplish in the next 20 minutes?")
                                .font(.spBody)
                                .foregroundStyle(Color.spTextSecondary.opacity(0.6))
                                .padding(16)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    }

                // File upload section
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        showFilePicker = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperclip")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Attach files")
                                .font(.spBody)
                        }
                        .foregroundStyle(Color.spTextSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.spBackgroundAlt)
                        .cornerRadius(SP.Radius.pill)
                    }

                    // Attached files shown as removable chips
                    if !attachedFiles.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(attachedFiles) { file in
                                fileChip(file)
                            }
                        }
                    }
                }

                Spacer()

                PrimaryCTA(title: "Analyze my task", trailingSystemImage: "arrow.right") {
                    withAnimation { step = .planReview }
                }
                .opacity(taskDescription.isEmpty ? 0.5 : 1)
                .disabled(taskDescription.isEmpty)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CloseButton(action: onDismiss)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
        .background(Color.spBackgroundAlt)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: Self.allowedFileTypes,
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
    }

    private func fileChip(_ file: AttachedFile) -> some View {
        HStack(spacing: 6) {
            Image(systemName: file.icon)
                .font(.system(size: 11, weight: .semibold))
            Text(file.name)
                .font(.spCaption)
                .lineLimit(1)
            Button {
                attachedFiles.removeAll { $0.id == file.id }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
            }
        }
        .foregroundStyle(Color.spTextPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.spPrimaryLight)
        .cornerRadius(SP.Radius.pill)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard let urls = try? result.get() else { return }
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }

            let name = url.lastPathComponent
            let ext = url.pathExtension.lowercased()
            let icon: String = switch ext {
            case "pdf": "doc.fill"
            case "docx", "doc": "doc.text.fill"
            case "jpg", "jpeg", "png": "photo.fill"
            default: "paperclip"
            }

            // Copy to temp storage (erased after backend returns plan)
            let tempDir = FileManager.default.temporaryDirectory
            let dest = tempDir.appendingPathComponent(UUID().uuidString + "." + ext)
            try? FileManager.default.copyItem(at: url, to: dest)

            attachedFiles.append(AttachedFile(name: name, icon: icon, localURL: dest))
        }
    }

    // MARK: - Step 2: Plan Review
    // Shows the mock task breakdown with time per task. Confirm or go back to edit.

    private var planReviewView: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 24) {
                Spacer().frame(height: 72)

                VStack(spacing: 4) {
                    Text("DEEP FOCUS")
                        .font(.spActivityLabel)
                        .foregroundStyle(Color.spTextSecondary)
                        .tracking(0.832)

                    Text("Your focus plan")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                }

                // Task breakdown list
                VStack(spacing: 0) {
                    ForEach(Array(taskPlan.enumerated()), id: \.offset) { index, task in
                        HStack {
                            Text("\(index + 1)")
                                .font(.spCaption)
                                .foregroundStyle(Color.spTextSecondary)
                                .frame(width: 24, height: 24)
                                .background(Color.spBackgroundAlt)
                                .clipShape(Circle())

                            Text(task.title)
                                .font(.spBody)
                                .foregroundStyle(Color.spTextPrimary)

                            Spacer()

                            Text("\(task.minutes) min")
                                .font(.spCaption)
                                .foregroundStyle(Color.spTextSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.spBackgroundAlt)
                                .cornerRadius(SP.Radius.pill)
                        }
                        .padding(.vertical, 14)

                        if index < taskPlan.count - 1 {
                            Divider().foregroundStyle(Color.spBorder)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(SP.Radius.card)

                // Total time
                HStack {
                    Text("Total")
                        .font(.spCardTitle)
                        .foregroundStyle(Color.spTextPrimary)
                    Spacer()
                    Text("\(taskPlan.reduce(0) { $0 + $1.minutes }) min")
                        .font(.spCardTitle)
                        .foregroundStyle(Color.spTextPrimary)
                }
                .padding(.horizontal, 4)

                Spacer()

                VStack(spacing: 12) {
                    PrimaryCTA(title: "Start focusing", trailingSystemImage: "arrow.right") {
                        cleanUpTempFiles()
                        withAnimation { step = .soundCheck }
                    }

                    // Edit goes back to task input
                    Button {
                        withAnimation { step = .taskInput }
                    } label: {
                        Text("Edit task")
                            .font(.spBody)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CloseButton(action: onDismiss)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
        .background(Color.spBackgroundAlt)
    }

    // MARK: - Step 3: Sound Check
    // Lightweight checkpoint directing user to iOS Background Sounds

    private var soundCheckView: some View {
        ZStack(alignment: .topTrailing) {
            // Everything centered as one group
            VStack(spacing: 24) {
                Image(systemName: "ear.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(Color.spPrimary)

                VStack(spacing: 8) {
                    Text("Set up your\nfocus sounds")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                        .multilineTextAlignment(.center)

                    Text("Open Control Center, tap the Hearing button, then turn on Background Sounds to help you focus.")
                        .font(.spBody)
                        .foregroundStyle(Color.spTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                PrimaryCTA(title: "I'm ready") {
                    startTimer()
                    withAnimation { step = .timer }
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CloseButton(action: onDismiss)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
        .background(Color.spBackgroundAlt)
    }

    // MARK: - Step 4: Timer
    // Circular progress ring with animated current task label

    private var timerView: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 32) {
                // Current task label — animates between sub-tasks as time progresses
                Text(currentFocusTask.title)
                    .font(.spCardTitle)
                    .foregroundStyle(Color.spTextSecondary)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: currentTaskIndex)
                    .id(currentTaskIndex)

                // Circular progress ring (240pt)
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.spBorder, lineWidth: 8)
                        .frame(width: 240, height: 240)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.spPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    // Time remaining
                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.spTimerDisplay)
                            .foregroundStyle(Color.spTextPrimary)
                        Text("remaining")
                            .font(.spCaption)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                }

                // Pause + Done buttons
                VStack(spacing: 12) {
                    PrimaryCTA(title: isPaused ? "Resume" : "Pause") {
                        togglePause()
                    }

                    Button {
                        timer?.invalidate()
                        withAnimation { step = .finishCheck }
                    } label: {
                        Text("I'm done")
                            .font(.spBody)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CloseButton(action: {
                timer?.invalidate()
                onDismiss()
            })
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
        .background(Color.spBackgroundAlt)
    }

    // MARK: - Step 5: Finish Check
    // "Did you finish?" with three options

    private var finishCheckView: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 24) {
                Text("🤔")
                    .font(.system(size: 64))

                Text("Did you finish?")
                    .font(.spPageTitle)
                    .foregroundStyle(Color.spTextPrimary)

                VStack(spacing: 12) {
                    // Done — goes to completion
                    PrimaryCTA(title: "Yes, I'm done!") {
                        withAnimation { step = .complete }
                    }

                    // Extend — adds 5 minutes and resumes timer
                    SecondaryCTA(title: "Add 5 more minutes") {
                        remainingSeconds += 5 * 60
                        totalSeconds += 5 * 60
                        startTimer()
                        withAnimation { step = .timer }
                    }

                    // Resume — back to timer at current position
                    Button {
                        startTimer()
                        withAnimation { step = .timer }
                    } label: {
                        Text("Resume where I left off")
                            .font(.spBody)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CloseButton(action: onDismiss)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
        .background(Color.spBackgroundAlt)
    }

    // MARK: - Timer helpers

    private var progress: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        return CGFloat(totalSeconds - remainingSeconds) / CGFloat(totalSeconds)
    }

    private var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // Determines which task is active based on elapsed time
    private var currentFocusTask: FocusTask {
        let elapsed = totalSeconds - remainingSeconds
        var accumulated = 0
        for (index, task) in taskPlan.enumerated() {
            accumulated += task.minutes * 60
            if elapsed < accumulated {
                // Update index for animation transitions
                DispatchQueue.main.async {
                    if currentTaskIndex != index {
                        currentTaskIndex = index
                    }
                }
                return task
            }
        }
        return taskPlan.last ?? FocusTask(title: "Focus", minutes: 20)
    }

    private func startTimer() {
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer?.invalidate()
                withAnimation { step = .finishCheck }
            }
        }
    }

    private func togglePause() {
        if isPaused {
            startTimer()
        } else {
            isPaused = true
            timer?.invalidate()
        }
    }

    // Remove temp files after backend processes them
    private func cleanUpTempFiles() {
        for file in attachedFiles {
            try? FileManager.default.removeItem(at: file.localURL)
        }
    }
}

// MARK: - Step enum

private enum Step {
    case taskInput, planReview, soundCheck, timer, finishCheck, complete
}

// MARK: - Supporting types

private struct FocusTask {
    let title: String
    let minutes: Int
}

private struct AttachedFile: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let localURL: URL
}

// MARK: - UTType extension for docx

// Supported file types for task attachment (jpg, png, pdf, docx)
extension DeepFocusView {
    fileprivate static let allowedFileTypes: [UTType] = {
        var types: [UTType] = [.jpeg, .png, .pdf]
        if let docx = UTType("org.openxmlformats.wordprocessingml.document") {
            types.append(docx)
        }
        return types
    }()
}

// MARK: - Simple flow layout for file chips

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}

#Preview {
    DeepFocusView(onDismiss: {})
}
