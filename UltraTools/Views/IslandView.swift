import SwiftUI

/// Визуальный «островок» — компонент в духе Dynamic Island для UltraTools.
struct IslandView: View {
    let preset: IslandPreset
    var width: CGFloat = 118
    var height: CGFloat = 36

    @State private var pulsing = false

    private var frameWidth: CGFloat {
        width * preset.scale * (preset.shape == .pill ? 1.45 : 1)
    }

    private var frameHeight: CGFloat {
        height * preset.scale
    }

    var body: some View {
        ZStack {
            shapeBody
        }
        .frame(width: frameWidth, height: frameHeight)
        .scaleEffect(pulsing ? 1.05 : 1.0)
        .shadow(color: .black.opacity(0.5), radius: 9, x: 0, y: 3)
        .onAppear { startPulse() }
        .onChange(of: preset.pulse) { _ in
            if preset.pulse {
                withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    pulsing = false
                }
            }
        }
    }

    private func makeShape() -> AnyShape {
        switch preset.shape {
        case .capsule:
            return AnyShape(Capsule())
        case .pill:
            return AnyShape(Capsule())
        case .rounded:
            return AnyShape(RoundedRectangle(cornerRadius: frameHeight * 0.28))
        case .squircle:
            return AnyShape(RoundedRectangle(cornerRadius: frameHeight * 0.45, style: .continuous))
        }
    }

    @ViewBuilder
    private var shapeBody: some View {
        let shape = makeShape()
        shape
            .fill(fillStyle)
            .overlay {
                shape.stroke(Color.white.opacity(0.18), lineWidth: 0.6)
            }
            .overlay {
                content
            }
    }

    private var fillStyle: AnyShapeStyle {
        if preset.gradient {
            return AnyShapeStyle(Theme.islandGradient(preset.colorIndex))
        } else {
            return AnyShapeStyle(Theme.islandColor(preset.colorIndex))
        }
    }

    @ViewBuilder
    private var content: some View {
        HStack(spacing: 7 * preset.scale) {
            switch preset.content {
            case .none:
                Circle()
                    .fill(Color(red: 0.10, green: 0.16, blue: 0.28))
                    .overlay {
                        Circle()
                            .fill(Color(red: 0.30, green: 0.50, blue: 0.90))
                            .frame(width: 4 * preset.scale, height: 4 * preset.scale)
                    }
                    .frame(width: 11 * preset.scale, height: 11 * preset.scale)

            case .music:
                Image(systemName: "music.note")
                    .font(.system(size: 12 * preset.scale, weight: .semibold))
                bar(progress: 0.62)
                Text("4:12")
                    .font(.system(size: 9 * preset.scale, weight: .medium).monospacedDigit())

            case .timer:
                Image(systemName: "timer")
                    .font(.system(size: 11 * preset.scale, weight: .semibold))
                Text("12:34")
                    .font(.system(size: 10 * preset.scale, weight: .semibold).monospacedDigit())

            case .call:
                Image(systemName: "phone.fill")
                    .font(.system(size: 11 * preset.scale, weight: .semibold))
                    .foregroundColor(Theme.green)
                HStack(spacing: 3) {
                    Circle().frame(width: 4 * preset.scale, height: 4 * preset.scale)
                    Circle().frame(width: 4 * preset.scale, height: 4 * preset.scale)
                    Circle().frame(width: 4 * preset.scale, height: 4 * preset.scale)
                }

            case .camera:
                Image(systemName: "video.fill")
                    .font(.system(size: 11 * preset.scale, weight: .semibold))
                Text("REC")
                    .font(.system(size: 8 * preset.scale, weight: .bold))
                Circle()
                    .fill(Theme.red)
                    .frame(width: 5 * preset.scale, height: 5 * preset.scale)

            case .charging:
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11 * preset.scale, weight: .semibold))
                    .foregroundColor(Theme.orange)
                Text("87%")
                    .font(.system(size: 10 * preset.scale, weight: .semibold).monospacedDigit())
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12 * preset.scale)
    }

    private func bar(progress: Double) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.25))
            .frame(width: 42 * preset.scale, height: 3)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color.white)
                    .frame(width: 42 * preset.scale * progress, height: 3)
            }
    }

    private func startPulse() {
        guard preset.pulse else { return }
        withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
            pulsing = true
        }
    }
}
