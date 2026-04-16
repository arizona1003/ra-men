import SwiftUI

struct RatingStars: View {
    let rating: Double
    var size: CGFloat = 14
    var color: Color = Theme.accent

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<5) { index in
                Image(systemName: symbol(for: index))
                    .foregroundStyle(color)
                    .font(.system(size: size))
            }
        }
    }

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 1.0 { return "star.fill" }
        if value >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

struct RatingPicker: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    rating = value
                } label: {
                    Image(systemName: value <= rating ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundStyle(value <= rating ? Theme.accent : Color.gray.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
