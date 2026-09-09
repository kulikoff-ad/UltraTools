import SwiftUI

/// Макет iPhone с живым статус-баром и островком.
struct PhoneMockup: View {
    @EnvironmentObject private var settings: SettingsStore
    let island: IslandPreset
    var islandSize: CGSize = CGSize(width: 112, height: 34)

    private let apps: [(icon: String, color: Color)] = [
        ("phone.fill", Theme.green),
        ("camera.fill", .gray),
        ("music.note", Theme.red),
        ("clock.fill", .indigo),
        ("envelope.fill", Theme.accent),
        ("photo.fill", .pink),
        ("gamecontroller.fill", Theme.orange),
        ("video.fill", .purple),
        ("calendar", .teal),
        ("sun.max", Color(red: 0.98, green: 0.80, blue: 0.30)),
        ("map.fill", .mint),
        ("book.fill", .brown)
    ]

    var body: some View {
        VStack(spacing: 0) {
            statusBar
            wallpaper
        }
        .frame(width: 272, height: 548)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.55), radius: 26, x: 0, y: 12)
    }

    // MARK: - Статус-бар

    private var statusBar: some View {
        ZStack(alignment: .top) {
            IslandView(preset: island, width: islandSize.width, height: islandSize.height)
                .padding(.top, 8)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text(context.date, format: settings.isOn("showSeconds")
                             ? .dateTime.hour().minute().second()
                             : .dateTime.hour().minute())
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    if settings.isOn("showCarrier") {
                        Text("ULTRA NET")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }

                Spacer()

                HStack(spacing: 5) {
                    if settings.isOn("showFPS") {
                        Text("60")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Theme.green)
                    }
                    Image(systemName: "wifi")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                    BatteryGlyph(
                        showPercent: settings.isOn("showBatteryPercent"),
                        level: settings.isOn("lowBattery") ? 0.12 : 0.87
                    )
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
        }
        .frame(height: 58)
    }

    // MARK: - Рабочий стол

    private var wallpaper: some View {
        let lowBatt = settings.isOn("lowBattery")
        let ultra = settings.isOn("ultraPower")
        let night = settings.isOn("autoNight")

        return ZStack {
            LinearGradient(
                colors: ultra
                    ? [Color(red: 0.10, green: 0.10, blue: 0.12), Color.black]
                    : night
                        ? [Color(red: 0.05, green: 0.05, blue: 0.16), Color(red: 0.01, green: 0.01, blue: 0.05)]
                        : [Color(red: 0.17, green: 0.10, blue: 0.36), Color(red: 0.03, green: 0.06, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                    spacing: 18
                ) {
                    ForEach(Array(apps.enumerated()), id: \.offset) { _, app in
                        appIcon(app.icon, app.color)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                Spacer()

                if lowBatt {
                    Text("⚠️ Низкий заряд батареи")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 10)
                }

                if !settings.isOn("hideDock") {
                    HStack(spacing: 16) {
                        appIcon("phone.fill", Theme.green, small: true)
                        appIcon("safari", Theme.accent, small: true)
                        appIcon("message.fill", Theme.green, small: true)
                        appIcon("music.note", Theme.red, small: true)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.bottom, 14)
                }
            }

            if settings.isOn("developerMode") {
                VStack {
                    HStack {
                        Spacer()
                        Text("DEV • 1.0.0")
                            .font(.system(size: 8, weight: .bold).monospaced())
                            .foregroundColor(Theme.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.5), in: Capsule())
                            .padding(.trailing, 10)
                    }
                    Spacer()
                }
            }
        }
        .brightness(settings.isOn("adaptiveBrightness") ? -0.06 : 0)
    }

    private func appIcon(_ symbol: String, _ color: Color, small: Bool = false) -> some View {
        let size: CGFloat = small ? 44 : 46
        return RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [color.opacity(0.95), color.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundColor(.white)
            }
    }
}

/// Иконка батареи для статус-бара макета.
struct BatteryGlyph: View {
    var showPercent: Bool
    var level: Double = 0.87

    var body: some View {
        HStack(spacing: 3) {
            if showPercent {
                Text(Int(level * 100).description)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white)
            }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    .frame(width: 21, height: 11)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(level > 0.2 ? Theme.green : Theme.red)
                    .frame(width: max(4, (21 - 4) * level), height: 7)
                    .padding(.leading, 2)
            }
            Rectangle()
                .fill(Color.white.opacity(0.45))
                .frame(width: 1.5, height: 4)
        }
    }
}
