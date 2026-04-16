import Foundation
import UIKit

/// 画像をアプリの Documents/review_photos に JPEG 保存/読込するヘルパー。
/// UserDefaults にはファイル名のみ保存し、バイナリはディスクに置く。
enum PhotoStore {
    private static let folderName = "review_photos"
    private static let jpegQuality: CGFloat = 0.85
    private static let maxDimension: CGFloat = 1600

    static var folderURL: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = base.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    static func url(for filename: String) -> URL {
        folderURL.appendingPathComponent(filename)
    }

    @discardableResult
    static func save(_ image: UIImage) -> String? {
        let resized = downscale(image)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        let target = url(for: filename)
        do {
            try data.write(to: target, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    static func loadImage(filename: String) -> UIImage? {
        UIImage(contentsOfFile: url(for: filename).path)
    }

    static func delete(filenames: [String]) {
        for name in filenames {
            try? FileManager.default.removeItem(at: url(for: name))
        }
    }

    static func deleteAll() {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: folderURL.path) else { return }
        for name in files {
            try? FileManager.default.removeItem(at: url(for: name))
        }
    }

    private static func downscale(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
