import SwiftUI

struct TaskRow: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(item.isDone ? .green : .white.opacity(0.55))
            }
            .buttonStyle(.plain)

            Text(item.text)
                .font(.system(size: 12))
                .foregroundColor(item.isDone ? .white.opacity(0.35) : .white.opacity(0.85))
                .strikethrough(item.isDone, color: .white.opacity(0.35))
                .lineLimit(isHovering ? nil : 2)
                .truncationMode(.tail)

            Spacer(minLength: 4)

            if isHovering {
                HStack(spacing: 5) {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .buttonStyle(.plain)

                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))
                        .help("Drag to reorder")
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovering ? Color.white.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
        .animation(.easeInOut(duration: 0.15), value: item.isDone)
    }
}
