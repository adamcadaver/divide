import Cocoa

enum Zone: Equatable {
    case leftHalf, rightHalf, topHalf, bottomHalf
    case maximize, center
    case topLeft, topRight, bottomLeft, bottomRight
    case leftThird, middleThird, rightThird
    case leftTwoThirds, rightTwoThirds
}

enum Layout {
    /// All rects are in Cocoa screen coordinates (origin bottom-left).
    static func frame(for zone: Zone, visibleFrame vf: CGRect) -> CGRect {
        switch zone {
        case .leftHalf:
            return CGRect(x: vf.minX, y: vf.minY, width: vf.width / 2, height: vf.height)
        case .rightHalf:
            return CGRect(x: vf.midX, y: vf.minY, width: vf.width / 2, height: vf.height)
        case .topHalf:
            return CGRect(x: vf.minX, y: vf.midY, width: vf.width, height: vf.height / 2)
        case .bottomHalf:
            return CGRect(x: vf.minX, y: vf.minY, width: vf.width, height: vf.height / 2)
        case .maximize:
            return vf
        case .center:
            let w = vf.width * (2.0 / 3.0)
            let h = vf.height * (2.0 / 3.0)
            return CGRect(x: vf.minX + (vf.width - w) / 2, y: vf.minY + (vf.height - h) / 2, width: w, height: h)
        case .topLeft:
            return CGRect(x: vf.minX, y: vf.midY, width: vf.width / 2, height: vf.height / 2)
        case .topRight:
            return CGRect(x: vf.midX, y: vf.midY, width: vf.width / 2, height: vf.height / 2)
        case .bottomLeft:
            return CGRect(x: vf.minX, y: vf.minY, width: vf.width / 2, height: vf.height / 2)
        case .bottomRight:
            return CGRect(x: vf.midX, y: vf.minY, width: vf.width / 2, height: vf.height / 2)
        case .leftThird:
            return CGRect(x: vf.minX, y: vf.minY, width: vf.width / 3, height: vf.height)
        case .middleThird:
            return CGRect(x: vf.minX + vf.width / 3, y: vf.minY, width: vf.width / 3, height: vf.height)
        case .rightThird:
            return CGRect(x: vf.minX + vf.width * 2 / 3, y: vf.minY, width: vf.width / 3, height: vf.height)
        case .leftTwoThirds:
            return CGRect(x: vf.minX, y: vf.minY, width: vf.width * 2 / 3, height: vf.height)
        case .rightTwoThirds:
            return CGRect(x: vf.minX + vf.width / 3, y: vf.minY, width: vf.width * 2 / 3, height: vf.height)
        }
    }
}
