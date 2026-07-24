import SwiftUI

struct ContentView: View {
    @StateObject private var store = TodoStore()
    @State private var newTaskText: String = ""
    @FocusState private var isInputFocused: Bool

    static let defaultWidth: CGFloat = 300
    static let defaultHeight: CGFloat = 400
    private static let cornerRadius: CGFloat = 12

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.2)
            taskList
            inputBar
        }
        .background(GlassBackground())
        .background(WindowConfigurator())
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .frame(minWidth: 280, idealWidth: Self.defaultWidth, minHeight: 340, idealHeight: Self.defaultHeight)
    }

    private var header: some View {
        HStack {
            Text("To-Do")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
            Spacer()
            if !store.items.isEmpty {
                Text("\(store.items.filter { !$0.isDone }.count) LEFT")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(0.8)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 7)
    }

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                if store.items.isEmpty {
                    emptyState
                } else {
                    ForEach(store.items) { item in
                        TaskRow(
                            item: item,
                            onToggle: { store.toggle(item) },
                            onDelete: {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    store.remove(item)
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 5) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.2))
            Text("No tasks yet")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var inputBar: some View {
        HStack(spacing: 6) {
            TextField("Add a task…", text: $newTaskText)
                .textFieldStyle(.plain)
                .focused($isInputFocused)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 9)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .onSubmit(addTask)

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 19))
                    .foregroundColor(.white.opacity(isInputBlank ? 0.25 : 0.85))
            }
            .buttonStyle(.plain)
            .disabled(isInputBlank)
        }
        .padding(10)
    }

    private var isInputBlank: Bool {
        newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addTask() {
        store.add(newTaskText)
        newTaskText = ""
        isInputFocused = true
    }
}
