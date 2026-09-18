//
//  Base64View.swift
//  UltraTools
//
//  Two-way Base64 conversion for UTF-8 text, with an optional
//  URL-safe alphabet and RFC 2045 line wrapping.
//

import SwiftUI

struct Base64View: View {

    enum Mode: String, CaseIterable, Identifiable {
        case encode = "Encode"
        case decode = "Decode"

        var id: String { rawValue }
    }

    @State private var mode: Mode = .encode
    @State private var inputText: String = "Hello, UltraTools! Привет, мир! 🚀"
    @State private var outputText: String = ""
    @State private var statusText: String = "Type some text, then tap Run."
    @State private var hasError: Bool = false
    @State private var wrapLines: Bool = false
    @State private var urlSafe: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                TextEditorCard(title: mode == .encode ? "Plain text" : "Base64",
                               placeholder: mode == .encode ? "Text to encode…" : "Base64 to decode…",
                               text: $inputText)

                Button {
                    run()
                } label: {
                    Label(mode == .encode ? "Encode to Base64" : "Decode to text",
                          systemImage: mode == .encode ? "lock.open" : "lock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                VStack(spacing: 0) {
                    Toggle(isOn: $wrapLines) {
                        Text("Wrap lines every 76 characters")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .disabled(mode == .decode)

                    Divider()
                        .padding(.horizontal, 10)

                    Toggle(isOn: $urlSafe) {
                        Text("URL-safe alphabet (- and _)")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

                HStack(spacing: 10) {
                    Button {
                        paste()
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        swap()
                    } label: {
                        Label("Use output", systemImage: "arrow.left.arrow.right")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(outputText.isEmpty)

                    Button(role: .destructive) {
                        clear()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(inputText.isEmpty && outputText.isEmpty)
                }

                StatusBanner(message: statusText, isError: hasError)

                if !outputText.isEmpty {
                    TextEditorCard(title: mode == .encode ? "Base64" : "Plain text",
                                   placeholder: "",
                                   text: $outputText,
                                   minHeight: 170)

                    CopyButton(text: outputText)
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("Base64")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: mode) { _ in
            run()
        }
    }

    // MARK: - Actions

    private func run() {
        switch mode {
        case .encode:
            encode()
        case .decode:
            decode()
        }
    }

    private func encode() {
        guard !inputText.isEmpty else {
            fail("Nothing to encode — type some text first.")
            return
        }

        let data = Data(inputText.utf8)
        var encoded = data.base64EncodedString(
            options: wrapLines ? [.lineLength76Characters, .endLineWithLineFeed] : []
        )

        if urlSafe {
            encoded = Base64Coder.toURLSafe(encoded)
        }

        outputText = encoded
        hasError = false
        statusText = "\(data.count) bytes → \(encoded.count) characters"
    }

    private func decode() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fail("Nothing to decode — paste some Base64 first.")
            return
        }

        let candidate = urlSafe
            ? Base64Coder.fromURLSafe(inputText)
            : inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = Data(base64Encoded: candidate, options: .ignoreUnknownCharacters) else {
            fail("That is not valid Base64 — check for stray characters.")
            return
        }

        guard !data.isEmpty else {
            fail("The decoded payload is empty.")
            return
        }

        guard let text = String(data: data, encoding: .utf8) else {
            fail("Decoded \(data.count) bytes, but they are not valid UTF-8 text.")
            return
        }

        outputText = text
        hasError = false
        statusText = "\(data.count) bytes → \(text.count) characters"
    }

    private func paste() {
        if let pasted = PasteboardReader.string() {
            inputText = pasted
            hasError = false
            statusText = "Pasted \(pasted.count) characters from the clipboard."
            run()
        } else {
            fail("The clipboard does not contain any text.")
        }
    }

    private func swap() {
        guard !outputText.isEmpty else { return }
        inputText = outputText
        mode = (mode == .encode) ? .decode : .encode
        run()
    }

    private func clear() {
        inputText = ""
        outputText = ""
        hasError = false
        statusText = "Cleared."
    }

    private func fail(_ message: String) {
        outputText = ""
        hasError = true
        statusText = message
    }
}

// MARK: - Alphabet helpers

enum Base64Coder {

    /// Standard Base64 → URL-safe Base64 (no padding).
    static func toURLSafe(_ value: String) -> String {
        value
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// URL-safe Base64 → standard Base64 with padding restored.
    static func fromURLSafe(_ value: String) -> String {
        var restored = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")

        let remainder = restored.count % 4
        if remainder > 0 {
            restored += String(repeating: "=", count: 4 - remainder)
        }
        return restored
    }
}

// MARK: - Preview

struct Base64View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Base64View()
        }
    }
}
