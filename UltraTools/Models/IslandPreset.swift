import SwiftUI

/// Форма островка.
enum IslandShape: String, CaseIterable, Codable, Identifiable {
    case capsule = "Капсула"
    case pill = "Пилл"
    case rounded = "Круглый"
    case squircle = "Сквиркл"

    var id: String { rawValue }
}

/// Содержимое островка (что «внутри» Dynamic Island).
enum IslandContent: String, CaseIterable, Codable, Identifiable {
    case none = "Пустой"
    case music = "Музыка"
    case timer = "Таймер"
    case call = "Звонок"
    case camera = "Камера"
    case charging = "Зарядка"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .none: return "circle"
        case .music: return "music.note"
        case .timer: return "timer"
        case .call: return "phone.fill"
        case .camera: return "video.fill"
        case .charging: return "bolt.fill"
        }
    }
}

/// Настройка собственного «островка».
struct IslandPreset: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String = "Мой островок"
    var shape: IslandShape = .capsule
    var content: IslandContent = .music
    var colorIndex: Int = 0
    var gradient: Bool = true
    var pulse: Bool = true
    var scale: Double = 1.0
}
