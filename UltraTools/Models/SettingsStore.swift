import SwiftUI

/// Одна «скрытая» настройка.
struct HiddenSetting: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let group: String
}

/// Все скрытые настройки UltraTools и их значения (UserDefaults).
final class SettingsStore: ObservableObject {
    private static let key = "hidden.settings.v1"

    static let groups: [String] = ["Экран", "Батарея", "Звук и тактильность", "Система"]

    static let all: [HiddenSetting] = [
        HiddenSetting(id: "showBatteryPercent", title: "Процент заряда",
                      subtitle: "Показывать % заряда на статус-баре",
                      icon: "battery.75percent", group: "Экран"),
        HiddenSetting(id: "showSeconds", title: "Секунды в часах",
                      subtitle: "Точное время с секундами",
                      icon: "stopwatch", group: "Экран"),
        HiddenSetting(id: "showCarrier", title: "Оператор сети",
                      subtitle: "Название оператора под временем",
                      icon: "antenna.radiowaves.left.and.right", group: "Экран"),
        HiddenSetting(id: "hideDock", title: "Скрыть Dock",
                      subtitle: "Убрать панель быстрых приложений",
                      icon: "square.grid.2x2.fill", group: "Экран"),
        HiddenSetting(id: "autoNight", title: "Авто-ночь",
                      subtitle: "Ночная подсветка экрана",
                      icon: "moon.fill", group: "Экран"),

        HiddenSetting(id: "lowBattery", title: "Низкий заряд: 12%",
                      subtitle: "Показывать предупреждение о разряде",
                      icon: "battery.25percent", group: "Батарея"),
        HiddenSetting(id: "adaptiveBrightness", title: "Адаптивная яркость",
                      subtitle: "Яркость по окружающему свету",
                      icon: "sun.max.fill", group: "Батарея"),
        HiddenSetting(id: "ultraPower", title: "Сверхэкономия",
                      subtitle: "Максимальная экономия энергии",
                      icon: "leaf.fill", group: "Батарея"),

        HiddenSetting(id: "hapticToggles", title: "Тактильные отклики",
                      subtitle: "Вибрация при переключении",
                      icon: "iphone.radiowaves.left.and.right", group: "Звук и тактильность"),
        HiddenSetting(id: "silentOnLock", title: "Тишина при блокировке",
                      subtitle: "Глушить звук на заблокированном экране",
                      icon: "bell.slash.fill", group: "Звук и тактильность"),

        HiddenSetting(id: "developerMode", title: "Режим разработчика",
                      subtitle: "Служебные данные и отладка",
                      icon: "hammer.fill", group: "Система"),
        HiddenSetting(id: "showFPS", title: "Счётчик FPS",
                      subtitle: "Показывать частоту кадров",
                      icon: "speedometer", group: "Система"),
        HiddenSetting(id: "autoUpdate", title: "Автообновление",
                      subtitle: "Обновлять приложения автоматически",
                      icon: "arrow.triangle.2.circlepath", group: "Система"),
        HiddenSetting(id: "privateSafari", title: "Приватный Safari",
                      subtitle: "Автоматически открывать приватную вкладку",
                      icon: "safari", group: "Система")
    ]

    static let defaults: [String: Bool] = [
        "showBatteryPercent": true,
        "showSeconds": false,
        "showCarrier": true,
        "hideDock": false,
        "autoNight": false,
        "lowBattery": false,
        "adaptiveBrightness": false,
        "ultraPower": false,
        "hapticToggles": true,
        "silentOnLock": false,
        "developerMode": false,
        "showFPS": false,
        "autoUpdate": true,
        "privateSafari": false
    ]

    @Published private(set) var values: [String: Bool] { didSet { save() } }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            values = decoded
        } else {
            values = Self.defaults
        }
    }

    func isOn(_ id: String) -> Bool {
        values[id] ?? Self.defaults[id] ?? false
    }

    func binding(_ id: String) -> Binding<Bool> {
        Binding(
            get: { self.values[id] ?? Self.defaults[id] ?? false },
            set: { newValue in self.values[id] = newValue }
        )
    }

    func settings(in group: String) -> [HiddenSetting] {
        Self.all.filter { $0.group == group }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}
