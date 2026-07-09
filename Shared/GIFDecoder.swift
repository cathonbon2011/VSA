import UIKit
import ImageIO

/// Decodes GIF data into an animated UIImage using ImageIO, honoring per-frame delays.
enum GIFDecoder {
    static func animatedImage(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else { return nil }

        if frameCount == 1, let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            return UIImage(cgImage: cgImage)
        }

        var images: [UIImage] = []
        var totalDuration: TimeInterval = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            let delay = frameDelay(source: source, index: index)
            totalDuration += delay
            images.append(UIImage(cgImage: cgImage))
        }

        guard !images.isEmpty else { return nil }
        return UIImage.animatedImage(with: images, duration: totalDuration > 0 ? totalDuration : Double(images.count) * 0.1)
    }

    private static func frameDelay(source: CGImageSource, index: Int) -> TimeInterval {
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else {
            return 0.1
        }

        let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double
        let delay = gifProperties[kCGImagePropertyGIFDelayTime] as? Double
        let duration = unclampedDelay ?? delay ?? 0.1
        // Guard against buggy 0-duration frames, matching common browser behavior.
        return duration < 0.02 ? 0.1 : duration
    }
}
