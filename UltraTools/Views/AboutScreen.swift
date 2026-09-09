import SwiftUI

/// Экран «О приложении».
struct AboutScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                logo
                featureCard
                buildCard
                footer
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
            .padding(.bottom, 30)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private var logo: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accent, Color(red: 0.62, green: 0.45, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                Capsule()
                    .fill(Color.black)
                    .frame(width: 44, height: 16)
            }
            .shadow(color: Theme.accent.opacity(0.4), radius: 18)

            Text("UltraTools")
                .font(.system(size: 26, weight: .bold))
            Text("Версия 1.0.0 (1)")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 6)
    }

    private var featureCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Возможности")
                .font(.system(size: 17, weight: .semibold))
            featureRow("moon.haze.fill", "Конструктор островка",
                       "Форма, цвет, градиент, пульсация и содержимое — с живым предпросмотром")
            featureRow("square.and.arrow.down", "Экспорт PNG",
                       "Сохраните свой островок как изображение")
            featureRow("slider.horizontal.3", "Скрытые настройки",
                       "14 переключателей в стиле iOS-модов с живым статус-баром")
            featureRow("square.stack.3d.up.fill", "Пресеты",
                       "Сохраняйте и переключайте конфигурации островка")
        }
        .utCard()
    }

    private func featureRow(_ icon: String, _ title: String, _ subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.accent)
                .frame(width: 32, height: 32)
                .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    private var buildCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Сборка IPA")
                .font(.system(size: 17, weight: .semibold))
            Text("На macOS с Xcode 15+ выполните в корне репозитория:")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            Text("./build_ipa.sh")
                .font(.system(size: 14, weight: .semibold).monospaced())
                .foregroundColor(Theme.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
            Text("Готовый UltraTools.ipa появится в папке build/. Подробности — в README.md.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .utCard()
    }

    private var footer: some View {
        Text("© 2026 UltraTools • Сделано на SwiftUI")
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.35))
    }
}
