import SwiftUI

/// Хранение пресетов островка (UserDefaults + JSON).
final class IslandStore: ObservableObject {
    private static let presetsKey = "island.presets.v1"
    private static let activeKey = "island.active.v1"

    @Published var presets: [IslandPreset] { didSet { savePresets() } }
    @Published var active: IslandPreset { didSet { saveActive() } }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.presetsKey),
           let decoded = try? JSONDecoder().decode([IslandPreset].self, from: data),
           !decoded.isEmpty {
            presets = decoded
        } else {
            presets = [
                IslandPreset(name: "Неон", shape: .capsule, content: .music,
                             colorIndex: 4, gradient: true, pulse: true, scale: 1.0),
                IslandPreset(name: "Классика", shape: .pill, content: .none,
                             colorIndex: 0, gradient: false, pulse: false, scale: 1.0)
            ]
        }

        if let data = UserDefaults.standard.data(forKey: Self.activeKey),
           let decoded = try? JSONDecoder().decode(IslandPreset.self, from: data) {
            active = decoded
        } else {
            active = IslandPreset()
        }
    }

    /// Сохранить текущий редактируемый островок в список пресетов.
    func saveCurrent() {
        if let index = presets.firstIndex(where: { $0.id == active.id }) {
            presets[index] = active
        } else {
            presets.append(active)
        }
    }

    /// Применить сохранённый пресет.
    func apply(_ preset: IslandPreset) {
        active = preset
    }

    func remove(_ preset: IslandPreset) {
        presets.removeAll { $0.id == preset.id }
    }

    private func savePresets() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: Self.presetsKey)
        }
    }

    private func saveActive() {
        if let data = try? JSONEncoder().encode(active) {
            UserDefaults.standard.set(data, forKey: Self.activeKey)
        }
    }
}
