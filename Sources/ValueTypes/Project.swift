import Foundation

public struct Project {
    public init() {
    }
    
    var pages: [Page] = []
}

public protocol PageObjectContainer {
    var pageObjects: [/*any*/ PageObject] { get set }
}

public typealias ID = UUID
public extension PageObjectContainer {
    subscript (id: ID) -> PageObject {
        get {
            pageObjects.first(where: {$0.id == id})!
        }
        set {
            pageObjects[pageObjects.firstIndex(where: {$0.id == id})!] = newValue
        }
    }
    
    func pageObject(at point: CGPoint) -> KeyPath<PageObjectContainer, PageObject>? {
        for pageObject in pageObjects.reversed() {
            if pageObject.frame.contains(point) {
                if let container = pageObject as? PageObjectContainer {
                    let keyPath = container.pageObject(at: point)
                }
                return \PageObjectContainer.[pageObject.id]
            }
        }
        
        return nil
    }
}

public struct Page : PageObjectContainer {
    public var frame: CGRect = .zero
    public var pageObjects: [/*any*/ PageObject] = []
}

public protocol PageObject  {
    var pageObjectData: PageObjectData { get set }
    var frame: CGRect { get set }
}

public extension PageObject {
    var id: UUID {
        pageObjectData.id
    }
    
    var frame: CGRect {
        get { pageObjectData.frame }
        set { pageObjectData.frame = newValue }
    }
}

public struct PageObjectData {
    public var id: UUID = UUID()
    public var frame: CGRect
}

public struct TextObject: PageObject {
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)
    public var text: String = ""
}

public struct ImageObject: PageObject {
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)
    public var imagePath: URL?
}

public struct Group: PageObject, PageObjectContainer {
    init(frame: CGRect, pageObjects: [PageObject]) {
        self.pageObjectData = PageObjectData(frame: frame)
        self.pageObjects = pageObjects
    }
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)
    public var pageObjects: [/*any*/ PageObject] = []
}

