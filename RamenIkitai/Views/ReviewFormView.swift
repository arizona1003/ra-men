import SwiftUI

struct ReviewFormView: View {
    let shop: Shop
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var visitedAt: Date = Date()
    @State private var menu: String = ""
    @State private var overallRating: Int = 4
    @State private var soupScore: Int = 3
    @State private var noodleScore: Int = 3
    @State private var toppingScore: Int = 3
    @State private var comment: String = ""

    private var canSubmit: Bool {
        !menu.trimmingCharacters(in: .whitespaces).isEmpty && overallRating > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text(shop.genre.emoji).font(.title)
                        VStack(alignment: .leading) {
                            Text(shop.name).font(.system(size: 16, weight: .bold))
                            Text("\(shop.prefecture) \(shop.area)")
                                .font(.caption)
                                .foregroundStyle(Theme.textSub)
                        }
                    }
                }

                Section("訪問情報") {
                    DatePicker("訪問日", selection: $visitedAt, displayedComponents: .date)
                    TextField("注文したメニュー", text: $menu, prompt: Text("例：特製醤油ラーメン"))
                }

                Section("総合評価") {
                    HStack {
                        Spacer()
                        RatingPicker(rating: $overallRating)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                Section("詳細評価") {
                    scorePicker("スープ", $soupScore)
                    scorePicker("麺", $noodleScore)
                    scorePicker("具・トッピング", $toppingScore)
                }

                Section("感想") {
                    TextEditor(text: $comment)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if comment.isEmpty {
                                Text("スープの味わい、麺の硬さ、お店の雰囲気など自由に記録しよう")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                        }
                }
            }
            .navigationTitle("ラー活を記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("投稿") { submit() }
                        .disabled(!canSubmit)
                        .bold()
                }
            }
        }
    }

    private func scorePicker(_ label: String, _ value: Binding<Int>) -> some View {
        HStack {
            Text(label)
            Spacer()
            Picker(label, selection: value) {
                ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)
        }
    }

    private func submit() {
        let review = Review(
            shopID: shop.id,
            visitedAt: visitedAt,
            menu: menu.trimmingCharacters(in: .whitespaces),
            overallRating: overallRating,
            soupScore: soupScore,
            noodleScore: noodleScore,
            toppingScore: toppingScore,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.addReview(review)
        dismiss()
    }
}

#Preview {
    ReviewFormView(shop: SampleData.makeShops()[0])
        .environmentObject(AppStore(preview: true))
}
