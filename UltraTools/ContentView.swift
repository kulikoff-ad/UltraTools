//
//  ContentView.swift
//  UltraTools
//
//  Root screen: the list of available tools, plus the small UI helpers
//  (copy button / paste helpers) shared by every tool view.
//

import SwiftUI

// MARK: - Model

struct Tool: Identifiable {
    enum Kind: String {
        case jsonFormatter
        case base64
        case uuid
    }

    let id = UUID()
    let kind: Kind
    let name: String
    let detail: String
    let systemImage: String
    let tint: Color
}

// MARK: - Root view

struct ContentView: View {
    private let tools: [Tool] = [
        Tool(kind: .jsonFormatter,
             name: "JSON Formatter",
             detail: "Beautify, minify and validate JSON",
             systemImage: "curlybraces",
             tint: .orange),
        Tool(kind: .base64,
             name: "Base64",
             detail: "Encode and decode Base64 text",
             systemImage: "number",
             tint: .blue),
        Tool(kind: .uuid,
             name: "UUID Generator",
             detail: "Create random (version 4) identifiers",
             systemImage: "key",
             tint: .purple)
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Developer tools")) {
                    ForEach(tools) { tool in
                        NavigationLink(destination: destination(for: tool)) {
                            ToolRow(tool: tool)
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Everything runs on-device.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("No network access, no analytics — your data never leaves the phone.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("UltraTools")
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private func destination(for tool: Tool) -> some View {
        switch tool.kind {
        case .jsonFormatter:
            JSONFormatterView()
        case .base64:
            Base64View()
        case .uuid:
            UUIDView()
        }
    }
}

// MARK: - Row

struct ToolRow: View {
    let tool: Tool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: tool.systemImage)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(tool.tint)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(tool.name)
                    .font(.headline)
                Text(tool.detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Shared UI helpers

/// Copies a string to the pasteboard and flashes a confirmation.
struct CopyButton: View {
    let text: String
    var title: String

    @State private var copied = false

    init(text: String, title: String = "Copy") {
        self.text = text
        self.title = title
    }

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                copied = false
            }
        } label: {
            Label(copied ? "Copied" : title,
                  systemImage: copied ? "checkmark" : "doc.on.doc")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

/// Reads the pasteboard, returning `nil` when it holds no plain text.
enum PasteboardReader {
    static func string() -> String? {
        UIPasteboard.general.string
    }
}

/// A monospaced, non-autocorrecting text card used by the formatter tools.
struct TextEditorCard: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 170

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(text.count) chars")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .frame(minHeight: minHeight, maxHeight: minHeight + 60)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
    }
}

/// A compact status line reporting the result of the last operation.
struct StatusBanner: View {
    let message: String
    var isError: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : .green)
                .padding(.top, 1)
            Text(message)
                .font(.footnote)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill((isError ? Color.red : Color.green).opacity(0.12))
        )
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
