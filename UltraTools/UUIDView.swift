//
//  UUIDView.swift
//  UltraTools
//
//  Generates random (RFC 4122 version 4) identifiers in bulk,
//  with formatting options and per-row copy.
//

import SwiftUI

struct UUIDView: View {

    struct Item: Identifiable {
        let id = UUID()
        let createdAt = Date()
    }

    @State private var count: Int = 1
    @State private var uppercase: Bool = false
    @State private var hyphens: Bool = true
    @State private var items: [Item] = []

    var body: some View {
        List {
            Section(header: Text("Options")) {
                Stepper(value: $count, in: 1...100, step: 1) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(count)")
                            .foregroundColor(.secondary)
                    }
                }

                Toggle(isOn: $uppercase) {
                    Text("Uppercase")
                }

                Toggle(isOn: $hyphens) {
                    Text("Hyphens")
                }
            }

            Section {
                Button {
                    generate()
                } label: {
                    Label("Generate \(count) UUID\(count == 1 ? "" : "s")",
                          systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }

                Button(role: .destructive) {
                    items.removeAll()
                } label: {
                    Label("Clear list", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .disabled(items.isEmpty)
            }

            if !items.isEmpty {
                Section(header: Text("Generated (\(items.count))")) {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(render(item.id))
                                    .font(.system(.body, design: .monospaced))
                                    .textSelection(.enabled)
                                Text(item.createdAt, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer(minLength: 8)

                            Button {
                                UIPasteboard.general.string = render(item.id)
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: delete)
                }

                Section {
                    CopyButton(text: items.map { render($0.id) }.joined(separator: "\n"),
                               title: "Copy all")
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Version 4 (random)")
                        .font(.footnote)
                    Text("UUIDs come from Foundation's UUID(), which uses a cryptographically strong random number generator — 122 random bits per identifier.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("UUID Generator")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if items.isEmpty {
                generate()
            }
        }
    }

    // MARK: - Actions

    private func generate() {
        let batch = (0..<count).map { _ in Item() }
        items = (batch + items).prefix(500).map { $0 }
    }

    private func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func render(_ uuid: UUID) -> String {
        var text = uuid.uuidString
        if !hyphens {
            text = text.replacingOccurrences(of: "-", with: "")
        }
        if !uppercase {
            text = text.lowercased()
        }
        return text
    }
}

// MARK: - Preview

struct UUIDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UUIDView()
        }
    }
}
