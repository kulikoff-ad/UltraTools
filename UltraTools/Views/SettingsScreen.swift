import SwiftUI
import UIKit

/// Экран скрытых настроек.
struct SettingsScreen: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                previewCard
                ForEach(SettingsStore.groups, id: \.self) { group in
                    groupCard(group)
                }
                disclaimer
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Скрытые настройки")
                .font(.system(size: 30, weight: .bold))
            Text("Тюнинг iOS в духе классических модов — с живым предпросмотром")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Предпросмотр статус-бара

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Предпросмотр статус-бара")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.55))

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 1) {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text(context.date, format: settings.isOn("showSeconds")
                             ? .dateTime.hour().minute().second()
                             : .dateTime.hour().minute())
                            .font(.system(size: 16, weight: .semibold))
                    }
                    if settings.isOn("showCarrier") {
                        Text("ULTRA NET")
                            .font(.system(size: 9, weight: .medium))
                            .opacity(0.8)
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    if settings.isOn("showFPS") {
                        Text("60 FPS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Theme.green)
                    }
                    Image(systemName: "wifi")
                        .font(.system(size: 12, weight: .semibold))
                    BatteryGlyph(
                        showPercent: settings.isOn("showBatteryPercent"),
                        level: settings.isOn("lowBattery") ? 0.12 : 0.87
                    )
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
        }
        .utCard()
    }

    // MARK: - Группы

    private func groupCard(_ group: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.accent)
                .textCase(.uppercase)
                .padding(.bottom, 6)

            let items = settings.settings(in: group)
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    SettingRow(setting: item, isOn: settings.binding(item.id), onToggle: haptic)
                        .padding(.vertical, 8)
                    if index < items.count - 1 {
                        Divider().overlay(Color.white.opacity(0.08))
                    }
                }
            }
        }
        .utCard()
    }

    private var disclaimer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Важно", systemImage: "info.circle.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.orange)
            Text("Настройки имитируют скрытые функции iOS и влияют на предпросмотр внутри приложения. Реальные системные настройки без джейлбрейка изменить невозможно.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .utCard()
    }

    private func haptic() {
        guard settings.isOn("hapticToggles") else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

/// Строка настройки с тумблером.
private struct SettingRow: View {
    let setting: HiddenSetting
    @Binding var isOn: Bool
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: setting.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.accent)
                .frame(width: 32, height: 32)
                .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text(setting.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text(setting.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Theme.green)
        }
        .contentShape(Rectangle())
        .onChange(of: isOn) { _ in onToggle() }
    }
}
