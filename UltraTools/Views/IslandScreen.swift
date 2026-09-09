import SwiftUI

/// Экран конструктора островка.
struct IslandScreen: View {
    @EnvironmentObject private var store: IslandStore
    @State private var exportURL: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                PhoneMockup(island: store.active)
                editorCard
                savedCard
                exportCard
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Островок")
                .font(.system(size: 30, weight: .bold))
            Text("Соберите свой Dynamic Island — предпросмотр обновляется вживую")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Конструктор

    private var editorCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Конструктор")
                .font(.system(size: 17, weight: .semibold))

            TextField("Название пресета", text: binding(\.name))
                .font(.system(size: 14))
                .padding(10)
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Text("Форма")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
                Picker("Форма", selection: binding(\.shape)) {
                    ForEach(IslandShape.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Содержимое")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(IslandContent.allCases) { c in
                            chip(c)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Цвет")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
                HStack(spacing: 10) {
                    ForEach(0..<Theme.islandColors.count, id: \.self) { i in
                        Circle()
                            .fill(Theme.islandColor(i))
                            .overlay {
                                Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Theme.accent, lineWidth: store.active.colorIndex == i ? 2.5 : 0)
                                    .padding(-3)
                            }
                            .frame(width: 26, height: 26)
                            .onTapGesture { set(\.colorIndex, i) }
                    }
                }
            }

            VStack(spacing: 14) {
                Toggle(isOn: binding(\.gradient)) {
                    optionRow("Градиент", "Плавный переход между двумя цветами")
                }
                Toggle(isOn: binding(\.pulse)) {
                    optionRow("Пульсация", "Островок мягко «дышит»")
                }
            }
            .tint(Theme.accent)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Размер")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                    Spacer()
                    Text("\(Int(store.active.scale * 100))%")
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .foregroundColor(.white.opacity(0.55))
                }
                Slider(value: binding(\.scale), in: 0.8...1.3)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.saveCurrent()
                }
            } label: {
                Label("Сохранить пресет", systemImage: "plus.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundColor(.black)
            }
        }
        .utCard()
    }

    private func optionRow(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private func chip(_ c: IslandContent) -> some View {
        let selected = store.active.content == c
        return Button {
            set(\.content, c)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: c.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(c.rawValue)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                selected ? AnyShapeStyle(Theme.accent.opacity(0.22)) : AnyShapeStyle(Color.white.opacity(0.05)),
                in: Capsule()
            )
            .overlay {
                Capsule().stroke(selected ? Theme.accent : Color.white.opacity(0.1), lineWidth: 1)
            }
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Пресеты

    private var savedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Мои пресеты")
                .font(.system(size: 17, weight: .semibold))
            if store.presets.isEmpty {
                Text("Пока пусто — настройте островок и сохраните его.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                ForEach(store.presets) { p in
                    presetRow(p)
                }
            }
        }
        .utCard()
    }

    private func presetRow(_ p: IslandPreset) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(p.gradient
                      ? AnyShapeStyle(Theme.islandGradient(p.colorIndex))
                      : AnyShapeStyle(Theme.islandColor(p.colorIndex)))
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 1) {
                Text(p.name)
                    .font(.system(size: 14, weight: .medium))
                Text("\(p.shape.rawValue) • \(p.content.rawValue)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            if store.active.id == p.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.accent)
                    .font(.system(size: 16))
            }

            Button {
                store.apply(p)
            } label: {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.7))

            Button {
                withAnimation { store.remove(p) }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Экспорт

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Экспорт")
                .font(.system(size: 17, weight: .semibold))
            Text("Скачайте свой островок как PNG-изображение.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            HStack(spacing: 10) {
                Button {
                    exportPNG()
                } label: {
                    Label("Сделать PNG", systemImage: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                }
                if let url = exportURL {
                    ShareLink(item: url) {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .utCard()
    }

    private func exportPNG() {
        let content = IslandView(preset: store.active, width: 150, height: 44)
            .padding(28)
            .frame(width: 320, height: 140)
            .background(Color(red: 0.05, green: 0.06, blue: 0.10))

        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        guard let image = renderer.uiImage, let data = image.pngData() else { return }

        let url = URL.documentsDirectory
            .appendingPathComponent("ultra-island-\(Int(Date().timeIntervalSince1970)).png")
        do {
            try data.write(to: url)
            exportURL = url
        } catch {
            exportURL = nil
        }
    }

    // MARK: - Хелперы

    private func binding<T>(_ keyPath: WritableKeyPath<IslandPreset, T>) -> Binding<T> {
        Binding(
            get: { store.active[keyPath: keyPath] },
            set: { newValue in store.active[keyPath: keyPath] = newValue }
        )
    }

    private func set<T>(_ keyPath: WritableKeyPath<IslandPreset, T>, _ value: T) {
        store.active[keyPath: keyPath] = value
    }
}
