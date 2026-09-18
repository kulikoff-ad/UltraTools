//
//  JSONFormatterView.swift
//  UltraTools
//
//  Pretty-prints, minifies and validates JSON documents.
//  Everything happens locally through Foundation's JSONSerialization.
//

import SwiftUI

struct JSONFormatterView: View {
    @State private var inputText: String = JSONFormatterView.sampleJSON
    @State private var outputText: String = ""
    @State private var statusText: String = "Paste JSON, then tap Format."
    @State private var hasError: Bool = false
    @State private var indentWidth: Int = 2
    @State private var sortKeys: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                TextEditorCard(title: "Input",
                               placeholder: "Paste JSON here…",
                               text: $inputText)

                HStack(spacing: 10) {
                    Button {
                        format()
                    } label: {
                        Label("Format", systemImage: "wand.and.stars")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        minify()
                    } label: {
                        Label("Minify", systemImage: "arrow.down.right.and.arrow.up.left")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        validate()
                    } label: {
                        Label("Check", systemImage: "checkmark.seal")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                VStack(spacing: 0) {
                    Stepper(value: $indentWidth, in: 2...8, step: 1) {
                        HStack {
                            Text("Indent")
                            Spacer()
                            Text("\(indentWidth) spaces")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)

                    Divider()
                        .padding(.horizontal, 10)

                    Toggle(isOn: $sortKeys) {
                        Text("Sort object keys")
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
                    TextEditorCard(title: "Output",
                                   placeholder: "",
                                   text: $outputText,
                                   minHeight: 190)

                    CopyButton(text: outputText)
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("JSON Formatter")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions

    private func format() {
        apply(pretty: true)
    }

    private func minify() {
        apply(pretty: false)
    }

    private func validate() {
        switch JSONFormatter.serialize(inputText,
                                      pretty: false,
                                      indent: indentWidth,
                                      sortKeys: sortKeys) {
        case .success(let result):
            hasError = false
            statusText = "Valid JSON · \(result.summary)"
        case .failure(let message):
            hasError = true
            statusText = message
        }
    }

    private func apply(pretty: Bool) {
        switch JSONFormatter.serialize(inputText,
                                      pretty: pretty,
                                      indent: indentWidth,
                                      sortKeys: sortKeys) {
        case .success(let result):
            outputText = result.text
            hasError = false
            statusText = (pretty ? "Formatted · " : "Minified · ") + result.summary
        case .failure(let message):
            outputText = ""
            hasError = true
            statusText = message
        }
    }

    private func paste() {
        if let pasted = PasteboardReader.string() {
            inputText = pasted
            statusText = "Pasted \(pasted.count) characters from the clipboard."
            hasError = false
        } else {
            hasError = true
            statusText = "The clipboard does not contain any text."
        }
    }

    private func clear() {
        inputText = ""
        outputText = ""
        hasError = false
        statusText = "Cleared."
    }

    // MARK: - Sample

    static let sampleJSON = """
    {"app":"UltraTools","version":1,"tools":["JSON Formatter","Base64","UUID"],\
    "offline":true,"author":{"name":"kulikoff-ad","url":"https://github.com/kulikoff-ad/UltraTools"}}
    """
}

// MARK: - Formatting engine

enum JSONFormatter {

    struct Output {
        let text: String
        let summary: String
    }

    enum Outcome {
        case success(Output)
        case failure(String)
    }

    /// Parses `source` and re-serialises it either pretty-printed or minified.
    static func serialize(_ source: String,
                          pretty: Bool,
                          indent: Int,
                          sortKeys: Bool) -> Outcome {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure("Nothing to process — paste some JSON first.")
        }

        guard let data = trimmed.data(using: .utf8) else {
            return .failure("The input is not valid UTF-8 text.")
        }

        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        } catch {
            return .failure(describe(error))
        }

        var writing: JSONSerialization.WritingOptions = [.fragmentsAllowed, .withoutEscapingSlashes]
        if sortKeys {
            writing.insert(.sortedKeys)
        }
        if pretty {
            writing.insert(.prettyPrinted)
        }

        let encoded: Data
        do {
            encoded = try JSONSerialization.data(withJSONObject: object, options: writing)
        } catch {
            return .failure("Could not re-encode the document: \(error.localizedDescription)")
        }

        guard var text = String(data: encoded, encoding: .utf8) else {
            return .failure("Could not render the JSON document as text.")
        }

        // JSONSerialization always pretty-prints with two spaces; re-indent on request.
        if pretty, indent != 2 {
            text = reindent(text, from: 2, to: indent)
        }

        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).count
        return .success(Output(text: text,
                               summary: "\(typeName(of: object)) · \(text.count) chars · \(lines) lines"))
    }

    /// Turns JSONSerialization's terse NSError into something a human can act on.
    private static func describe(_ error: Error) -> String {
        let nsError = error as NSError
        if let debug = nsError.userInfo["NSDebugDescription"] as? String {
            return "Invalid JSON — \(debug)"
        }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            return "Invalid JSON — \(underlying.localizedDescription)"
        }
        return "Invalid JSON — \(error.localizedDescription)"
    }

    static func typeName(of object: Any) -> String {
        switch object {
        case is [String: Any]:
            return "object"
        case is [Any]:
            return "array"
        case is String:
            return "string"
        case is Bool:
            return "boolean"
        case is NSNumber:
            return "number"
        case is NSNull:
            return "null"
        default:
            return "value"
        }
    }

    static func reindent(_ text: String, from source: Int, to target: Int) -> String {
        guard source > 0, target > 0, source != target else { return text }
        return text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line -> String in
                let content = String(line)
                let leading = content.prefix(while: { $0 == " " }).count
                let level = leading / source
                let remainder = leading % source
                let spaces = String(repeating: " ", count: level * target + remainder)
                return spaces + content.dropFirst(leading)
            }
            .joined(separator: "\n")
    }
}

// MARK: - Preview

struct JSONFormatterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JSONFormatterView()
        }
    }
}
