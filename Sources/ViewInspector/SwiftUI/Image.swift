import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Image: KnownViewType {
        public static let typePrefix: String = "Image"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func image() throws -> InspectableView<ViewType.Image> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func image(_ index: Int) throws -> InspectableView<ViewType.Image> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Image: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 1) { index in
            let image = try Inspector.cast(value: parent.content.view, type: Image.self)
                .rootImage()
            let labelView = try Inspector.attribute(path: "provider|base|label", value: image)
            let content = try Inspector.unwrap(content: Content(labelView))
            return try .init(content, parent: parent, call: "labelView()")
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Image {
    
    func actualImage() throws -> Image {
        return try Inspector.cast(value: content.view, type: Image.self)
    }
    
    func labelView() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0).text()
    }
}

// MARK: - Deprecated Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Image {
    
    @available(*, deprecated, message: "Use actualImage().name() instead")
    func imageName() throws -> String {
        return try actualImage().name()
    }
    
    #if os(iOS) || os(tvOS)
    @available(*, deprecated, message: "Use actualImage().uiImage() instead")
    func uiImage() throws -> UIImage? {
        return try actualImage().uiImage()
    }
    #else
    @available(*, deprecated, message: "Use actualImage().nsImage() instead")
    func nsImage() throws -> NSImage? {
        return try actualImage().nsImage()
    }
    #endif
    
    @available(*, deprecated, message: "Use actualImage().cgImage() instead")
    func cgImage() throws -> CGImage? {
        return try actualImage().cgImage()
    }
    
    @available(*, deprecated, message: "Use actualImage().orientation() instead")
    func orientation() throws -> Image.Orientation {
        return try actualImage().orientation()
    }
    
    @available(*, deprecated, message: "Use actualImage().scale() instead")
    func scale() throws -> CGFloat {
        return try actualImage().scale()
    }
}

// MARK: - Image

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SwiftUI.Image {
    
    func rootImage() throws -> Image {
        return try Inspector.cast(value: imageContent().view, type: Image.self)
    }
    
    func name() throws -> String {
        return try Inspector
            .attribute(label: "name", value: rawImage(), type: String.self)
    }
    
    #if os(iOS) || os(tvOS)
    func uiImage() throws -> UIImage {
        return try Inspector.cast(value: try rawImage(), type: UIImage.self)
    }
    #else
    func nsImage() throws -> NSImage {
        return try Inspector.cast(value: try rawImage(), type: NSImage.self)
    }
    #endif
    
    func cgImage() throws -> CGImage {
        return try Inspector
            .attribute(label: "image", value: rawImage(), type: CGImage.self)
    }
    
    func orientation() throws -> Image.Orientation {
        return try Inspector
            .attribute(label: "orientation", value: rawImage(), type: Image.Orientation.self)
    }
    
    func scale() throws -> CGFloat {
        return try Inspector
            .attribute(label: "scale", value: rawImage(), type: CGFloat.self)
    }
    
    private func rawImage() throws -> Any {
        return try Inspector.attribute(path: "provider|base", value: try imageContent().view)
    }
    
    private func imageContent() throws -> Content {
        return try Inspector.unwrap(image: self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Inspector {
    static func unwrap(image: Image) throws -> Content {
        let provider = try Inspector.attribute(path: "provider|base", value: image)
        if let child = try? Inspector.attribute(label: "base", value: provider, type: Image.self) {
            let content = try unwrap(image: child)
            return Content(content.view, modifiers: content.modifiers + [provider])
        }
        return Content(image, modifiers: [])
    }
}
