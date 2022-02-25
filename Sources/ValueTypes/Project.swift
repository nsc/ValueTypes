import Foundation

public struct Project {
    public init() {
    }
    
    var pages: [Page] = []
}

public struct Page {
    public var frame: CGRect = .zero
    var pageObjects: [PageObject] = []
}

public protocol PageObject {
    var frame: CGRect { get set }
}

public struct TextObject: PageObject {
    public var frame: CGRect = .zero
    public var text: String = ""
}

public struct ImageObject: PageObject {
    public var frame: CGRect = .zero
    public var imagePath: URL?
}

public struct Group: PageObject {
    public var frame: CGRect = .zero
    public var pageObjects: [PageObject] = []
}

