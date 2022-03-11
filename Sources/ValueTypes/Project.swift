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

    /// Returns a strongly typed page object (no existential)
    /// if the caller knows the type statically.
    ///
    /// The concrete type `T` must be provided by the caller from the context
    /// (i.e. via type inference). We can't pass it as an argument because we
    /// want to use this subscript in key paths, which requires all arguments
    /// to be Hashable.
    subscript<T: PageObject> (typed id: ID) -> T {
        get {
            self[id] as! T
        }
        set {
            self[id] = newValue
        }
    }

    func pageObject(at point: CGPoint) -> KeyPath<Self, PageObject>? {
        /// Helper function for constructing a key path that traverses through a PageObjectContainer.
        func pageObjectAtPointInContainer<C: PageObject & PageObjectContainer>(_ container: C) -> KeyPath<Self, PageObject> {
            guard let childKeyPath = container.pageObject(at: point) else {
                // Container has no child at this coordinate → return key path to container
                return \Self.[container.id]
            }
            let baseKeyPath: WritableKeyPath<Self, C> = \Self.[typed: container.id]
            return baseKeyPath.appending(path: childKeyPath)
        }

        for pageObject in pageObjects.reversed() where pageObject.frame.contains(point) {
            if let container = pageObject as? (PageObject & PageObjectContainer) {
                // There's a container at the coordinate → traverse into container.
                return _openExistential(container, do: pageObjectAtPointInContainer)
            } else {
                // There's a non-container PageObject at the coordinate → we found what we're looking for.
                return \Self.[pageObject.id]
            }
        }
        
        return nil
    }
}

public struct Page : PageObjectContainer {
    public var frame: CGRect = .zero
    public var pageObjects: [/*any*/ PageObject] = []
}

public protocol PageObject {
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

public struct PageObjectData: Equatable {
    public var id: UUID = UUID()
    public var frame: CGRect
}

public struct TextObject: PageObject, Equatable {
    public var pageObjectData: PageObjectData = PageObjectData(frame: .zero)
    public var text: String = ""
}

public struct ImageObject: PageObject, Equatable {
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

