import Foundation

public struct Project {
    public init() {
    }
    
    var pages: [Page] = []
}

public typealias ID = UUID

public protocol Node {
    var id: ID { get }
    var children: [/*any*/ Node] { get set }
}

public protocol PageObject: Node {
    var pageObjectData: PageObjectData { get set }
    var frame: CGRect { get set }
}

public extension PageObject {
    var id: ID {
        pageObjectData.id
    }
    
    var frame: CGRect {
        get { pageObjectData.frame }
        set { pageObjectData.frame = newValue }
    }

    var children: [Node] {
        get { return [] }
        set { fatalError("Doesn't have children") }
    }
}

public struct PageObjectData: Equatable {
    public var id: ID = UUID()
    public var frame: CGRect
}

public struct Page : Node {
    public var id: ID
    public var size: CGSize = .zero
    public var pageObjects: [/*any*/ PageObject] = []

    public var children: [/*any*/ Node] {
        get { pageObjects }
        set { pageObjects = newValue as! [PageObject] }
    }
}

public struct TextObject: PageObject, Equatable {
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)
    public var text: String = ""
}

public struct ImageObject: PageObject, Equatable {
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)
    public var imagePath: URL?
}

public struct Group: PageObject {
    init(frame: CGRect, pageObjects: [PageObject]) {
        self.pageObjectData = PageObjectData(frame: frame)
        self.children = pageObjects
    }
    public var pageObjects: [/*any*/ PageObject] = []
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)

    public var children: [/*any*/ Node] {
        get { pageObjects }
        set { pageObjects = newValue as! [/*any*/ PageObject] }
    }
}

public extension Node {
    subscript (id: ID) -> Node {
        get {
            return children.first(where: {$0.id == id})!
        }
        set {
            children[children.firstIndex(where: {$0.id == id})!] = newValue
        }
    }

    func pageObject(at point: CGPoint) -> WritableKeyPath<Node, Node>? {
        for child in children.reversed() where (child as? PageObject)?.frame.contains(point) ?? false {
            if let subChild = child.pageObject(at: point) {
                let base = \Node.[child.id]
                return base.appending(path: subChild)
            } else {
                // There's a non-container PageObject at the coordinate → we found what we're looking for.
                return \Node.[child.id]
            }
        }

        return nil
    }
}
