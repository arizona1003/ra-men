import SwiftUI

/// ディスク上のファイル名から UIImage を読み込んで表示する Image ラッパー
struct StoredPhotoView: View {
    let filename: String
    var contentMode: ContentMode = .fill

    var body: some View {
        if let uiImage = PhotoStore.loadImage(filename: filename) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            ZStack {
                Theme.surfaceMuted
                Image(systemName: "photo")
                    .foregroundStyle(Theme.textSub)
            }
        }
    }
}

/// 複数サムネイルを横スクロールで表示。タップで全画面ビューアを開く。
struct PhotoThumbnailStrip: View {
    let filenames: [String]
    var size: CGFloat = 84

    @State private var viewerIndex: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(filenames.enumerated()), id: \.offset) { index, name in
                    Button {
                        viewerIndex = index
                    } label: {
                        StoredPhotoView(filename: name)
                            .frame(width: size, height: size)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .fullScreenCover(item: Binding(
            get: { viewerIndex.map { IndexBox(id: $0) } },
            set: { viewerIndex = $0?.id }
        )) { box in
            PhotoViewer(filenames: filenames, startIndex: box.id) {
                viewerIndex = nil
            }
        }
    }

    private struct IndexBox: Identifiable { let id: Int }
}

/// 全画面のフォトビューア（ピンチズーム + ページング）
struct PhotoViewer: View {
    let filenames: [String]
    let startIndex: Int
    let onClose: () -> Void

    @State private var selection: Int = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            TabView(selection: $selection) {
                ForEach(Array(filenames.enumerated()), id: \.offset) { index, name in
                    ZoomableImage(filename: name).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: filenames.count > 1 ? .always : .never))
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
            .ignoresSafeArea()

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.5))
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .padding()
        }
        .onAppear { selection = startIndex }
    }
}

private struct ZoomableImage: View {
    let filename: String
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            StoredPhotoView(filename: filename, contentMode: .fit)
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(max(lastScale * value, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring) {
                        if scale > 1.01 {
                            scale = 1; lastScale = 1
                        } else {
                            scale = 2; lastScale = 2
                        }
                    }
                }
        }
    }
}
