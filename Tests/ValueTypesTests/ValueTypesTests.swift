import XCTest
@testable import ValueTypes

final class ValueTypesTests: XCTestCase {
    func testExample() throws {
        var project = makeProject()
        
        // Shift all objects inside of a group on some page
        for i in project.pages.indices {
            
            for index in project.pages[i].pageObjects.indices {
                project.pages[i][at: index, asType: Group.self]?.forEachPageObject { pageObject in 
                    let shiftedFrame = pageObject.frame.applying(CGAffineTransform(translationX: 10, y: 10))
                    pageObject.frame = shiftedFrame
                }
            }
            
//            project.pages[i].forEachPageObject { pageObject in
//                if var group = pageObject as? Group {
//                    group.forEachPageObject { pageObject in
//                        let shiftedFrame = pageObject.frame.applying(CGAffineTransform(translationX: 10, y: 10))
//                        pageObject.frame = shiftedFrame
//                    }
//                    pageObject = group
//                }
//            }
        }
    }

    func testPageObjectAtFound() throws {
        let text = TextObject(
            pageObjectData: .init(frame: CGRect(x: 200, y: 200, width: 100, height: 100)),
            text: ""
        )
        let page = Page(
            id: UUID(),
            size: CGSize(width: 2000, height: 2000),
            pageObjects: [text]
        )

        let keyPath = try XCTUnwrap(page.pageObject(at: CGPoint(x: 250, y: 250)))
        let child = page[keyPath: keyPath]
        XCTAssertEqual(child as? TextObject, text)
    }

    func testPageObjectAtNotFound() throws {
        let text = TextObject(
            pageObjectData: .init(frame: CGRect(x: 200, y: 200, width: 100, height: 100)),
            text: ""
        )
        let page = Page(
            id: UUID(),
            size: CGSize(width: 2000, height: 2000),
            pageObjects: [text]
        )

        let keyPath = page.pageObject(at: CGPoint(x: 500, y: 500))
        XCTAssertNil(keyPath)
    }

    func testPageObjectAtInContainer() throws {
        let text = TextObject(
            pageObjectData: .init(frame: CGRect(x: 200, y: 200, width: 100, height: 100)),
            text: ""
        )
        let group = Group(
            frame: CGRect(x: 100, y: 100, width: 800, height: 400),
            pageObjects: [text]
        )
        let page = Page(
            id: UUID(),
            size: CGSize(width: 2000, height: 2000),
            pageObjects: [group]
        )

        let keyPath = try XCTUnwrap(page.pageObject(at: CGPoint(x: 250, y: 250)))
        let child = page[keyPath: keyPath]
        let typedChild = try XCTUnwrap(child as? TextObject)
        XCTAssertEqual(typedChild, text)
    }

    func testPageObjectAtWithMutation() throws {
        let text = TextObject(
            pageObjectData: .init(frame: CGRect(x: 200, y: 200, width: 100, height: 100)),
            text: ""
        )
        let group = Group(
            frame: CGRect(x: 100, y: 100, width: 800, height: 400),
            pageObjects: [text]
        )
        var page = Page(
            id: UUID(),
            size: CGSize(width: 2000, height: 2000),
            pageObjects: [group]
        )

        let keyPath = try XCTUnwrap(page.pageObject(at: CGPoint(x: 250, y: 250)))
        page.mutate(keyPath: keyPath, asType: TextObject.self) { textObject in
            textObject.text = "Hello"
        }
        try XCTAssertEqual(XCTUnwrap(page[keyPath: keyPath] as? TextObject).text, "Hello")
    }


    func makeProject() -> Project {
        let sheetSize = CGSize(width: 2000, height: 500)
        
        var project = Project()
        project.pages = [
            Page(id: UUID(), size: sheetSize),
            Page(id: UUID(), size: sheetSize),
        ]
        let group = Group(
            frame: CGRect(x: 100, y: 100, width: 800, height: 400),
            pageObjects: [
                TextObject(pageObjectData: .init(frame: CGRect(x: 200, y: 200, width: 100, height: 100)), text: ""),
                ImageObject(pageObjectData: .init(frame: CGRect(x: 400, y: 200, width: 100, height: 100)), imagePath: nil)
            ]
        )
        project.pages[0].pageObjects = [TextObject(), ImageObject(), group]
        
        return project
    }
}

extension Node {
    subscript<T: Node> (at index: Int, asType type: T.Type) -> T? {
        get {
            children[index] as? T
        }
        set {
            if let value = newValue {
                children[index] = value
            }
        }
    }

    subscript<T: Node> (keyPath keyPath: WritableKeyPath<Node, Node>, asType type: T.Type) -> T? {
        get { self[keyPath: keyPath] as? T }
        set {
            guard let newValue = newValue else {
                fatalError("Must not be nil")
            }
            var selfCopy = self as Node
            selfCopy[keyPath: keyPath] = newValue
            self = selfCopy as! Self
        }
    }

    mutating func mutate<T: Node> (keyPath: WritableKeyPath<Node, Node>, asType type: T.Type, body: (inout T) -> Void) {
        guard var copy = self[keyPath: keyPath] as? T else {
            return
        }
        body(&copy)
        self[keyPath: keyPath, asType: T.self] = copy
    }
}

extension Group {
    mutating func forEachPageObject(handler: (inout PageObject) -> ()) {
        for j in pageObjects.indices {
            handler(&pageObjects[j])
        }
    }
}

extension Page {
    mutating func forEachPageObject(handler: (inout PageObject) -> ()) {
        for j in pageObjects.indices {
            handler(&pageObjects[j])
        }
    }
    
    mutating func mutateObjects<T : PageObject>(ofType type: T.Type, handler: (inout T) -> ()) {
        for j in pageObjects.indices {
            let pageObject = pageObjects[j]
        
            if var object = pageObject as? T {
                handler(&object)
                pageObjects[j] = object
            }
        }
    }
}
