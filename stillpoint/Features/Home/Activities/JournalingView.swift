import SwiftUI
import SwiftData

struct JournalingView: View {
    let onComplete: (Int) -> Void
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var text = ""
    @State private var entry: LocalJournalEntry?
    @State private var isComplete = false
    @State private var saveTask: Task<Void, Never>?

    private let xpReward = 25
    private let minWords = 50

    private var wordCount: Int {
        text.split(separator: " ", omittingEmptySubsequences: true).count
    }

    private var isDoneEnabled: Bool {
        wordCount >= minWords
    }

    var body: some View {
        if isComplete {
            ActivityCompleteView(
                activityName: "Journaling",
                xpEarned: xpReward,
                onDone: {
                    onComplete(xpReward)
                    onDismiss()
                }
            )
        } else {
            journalingContent
        }
    }

    // MARK: - Content

    private var journalingContent: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 8)

            promptBanner
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 20)

            textEditor
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 12)

            footer
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
        .background(Color.spBackgroundAlt)
        .onAppear(perform: loadTodayEntry)
        .onDisappear { saveTask?.cancel() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            CloseButton(action: {
                save()
                onDismiss()
            })

            Spacer()

            VStack(spacing: 2) {
                Text("JOURNAL")
                    .font(.spActivityLabel)
                    .foregroundStyle(Color.spTextSecondary)
                    .tracking(0.832)

                Text("Free Writing")
                    .font(.spHeading)
                    .foregroundStyle(Color.spTextPrimary)
            }

            Spacer()

            // Placeholder to balance the close button
            Color.clear
                .frame(width: 40, height: 40)
        }
    }

    // MARK: - Prompt

    private var promptBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.spPrimary)

            Text(dailyPrompt)
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spPrimaryLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: SP.Radius.icon))
    }

    // MARK: - Text Editor

    private var textEditor: some View {
        TextEditor(text: $text)
            .font(.spBodyRegular)
            .foregroundStyle(Color.spTextPrimary)
            .scrollContentBackground(.hidden)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: SP.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: SP.Radius.card)
                    .stroke(Color.spBorder, lineWidth: 1)
            )
            .overlay(alignment: .topLeading, content: {
                if text.isEmpty {
                    Text("Start writing...")
                        .font(.spBodyRegular)
                        .foregroundStyle(Color.spTextSecondary.opacity(0.5))
                        .padding(20)
                        .allowsHitTesting(false)
                }
            })
            .onChange(of: text) { debouncedSave() }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            HStack(spacing: 4) {
                Text("\(wordCount)")
                    .font(.spCardTitle)
                    .foregroundStyle(isDoneEnabled ? Color.spTextPrimary : Color.spTextSecondary)
                Text("/ \(minWords) words")
                    .font(.spBody)
                    .foregroundStyle(Color.spTextSecondary)
            }

            Spacer()

            Button(action: { save(); withAnimation { isComplete = true } }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Done")
                        .font(.spCardTitle)
                }
                .foregroundStyle(Color.spTextPrimary.opacity(isDoneEnabled ? 1 : 0.4))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isDoneEnabled ? Color.spPrimary : Color.spPrimaryLight.opacity(0.5))
                .clipShape(Capsule())
            }
            .disabled(!isDoneEnabled)
        }
    }

    // MARK: - Persistence

    private func loadTodayEntry() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<LocalJournalEntry>(
            predicate: #Predicate { $0.createdAt >= startOfDay && $0.createdAt < endOfDay },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            entry = existing
            text = existing.content
        } else {
            let newEntry = LocalJournalEntry()
            modelContext.insert(newEntry)
            entry = newEntry
        }
    }

    private func save() {
        saveTask?.cancel()
        guard let entry else { return }
        entry.content = text
        entry.updatedAt = .now
        try? modelContext.save()
    }

    private func debouncedSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            save()
        }
    }

    // MARK: - Daily Prompt

    private var dailyPrompt: String {
        let prompts = [
            "What are you grateful for today?",
            "What's on your mind right now?",
            "Describe a moment that made you smile today.",
            "What challenge are you working through?",
            "What would make tomorrow great?",
            "How are you really feeling right now?",
            "What did you learn about yourself recently?",
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return prompts[dayOfYear % prompts.count]
    }
}

#Preview {
    JournalingView(onComplete: { _ in }, onDismiss: {})
        .modelContainer(for: LocalJournalEntry.self, inMemory: true)
}
