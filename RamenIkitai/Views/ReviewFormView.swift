import SwiftUI
import PhotosUI

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

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var pickedImages: [UIImage] = []
    @State private var isProcessingPhotos = false

    private let maxPhotos = 4

    private var canSubmit: Bool {
        !menu.trimmingCharacters(in: .whitespaces).isEmpty && overallRating > 0 && !isProcessingPhotos
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

                Section(header: photoSectionHeader) {
                    photoPickerContent
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
            .onChange(of: pickerItems) { _, newItems in
                loadPickedImages(newItems)
            }
        }
    }

    private var photoSectionHeader: some View {
        HStack {
            Text("写真")
            Spacer()
            Text("\(pickedImages.count) / \(maxPhotos)")
                .font(.caption2)
                .foregroundStyle(Theme.textSub)
        }
    }

    @ViewBuilder
    private var photoPickerContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(pickedImages.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 92, height: 92)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Button {
                            removeImage(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white, Color.black.opacity(0.6))
                        }
                        .padding(4)
                    }
                }

                if pickedImages.count < maxPhotos {
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: maxPhotos - pickedImages.count,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack(spacing: 4) {
                            if isProcessingPhotos {
                                ProgressView()
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 22))
                            }
                            Text("追加")
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundStyle(Theme.primary)
                        .frame(width: 92, height: 92)
                        .background(Theme.primary.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Theme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        )
                    }
                    .disabled(isProcessingPhotos)
                }
            }
            .padding(.vertical, 4)
        }

        if !pickedImages.isEmpty {
            Text("写真は最大 \(maxPhotos) 枚まで添付できます")
                .font(.caption2)
                .foregroundStyle(Theme.textSub)
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

    private func removeImage(at index: Int) {
        guard pickedImages.indices.contains(index) else { return }
        pickedImages.remove(at: index)
        if pickerItems.indices.contains(index) {
            pickerItems.remove(at: index)
        }
    }

    private func loadPickedImages(_ items: [PhotosPickerItem]) {
        guard items.count > pickedImages.count else { return }
        let newItems = Array(items.suffix(items.count - pickedImages.count))
        isProcessingPhotos = true
        Task {
            var appended: [UIImage] = []
            for item in newItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    appended.append(image)
                }
            }
            await MainActor.run {
                pickedImages.append(contentsOf: appended)
                isProcessingPhotos = false
            }
        }
    }

    private func submit() {
        let savedNames = pickedImages.compactMap { PhotoStore.save($0) }
        let review = Review(
            shopID: shop.id,
            visitedAt: visitedAt,
            menu: menu.trimmingCharacters(in: .whitespaces),
            overallRating: overallRating,
            soupScore: soupScore,
            noodleScore: noodleScore,
            toppingScore: toppingScore,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
            photoFilenames: savedNames
        )
        store.addReview(review)
        dismiss()
    }
}

#Preview {
    ReviewFormView(shop: SampleData.makeShops()[0])
        .environmentObject(AppStore(preview: true))
}
