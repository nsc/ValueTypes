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
    
    func makeProject() -> Project {
        let sheetSize = CGSize(width: 2000, height: 500)
        
        var project = Project()
        project.pages = [Page(frame: CGRect(origin: .zero, size: sheetSize)), Page(frame: CGRect(origin: .zero, size: sheetSize))]
        let group = Group(frame: CGRect(x: 100, y: 100, width: 800, height: 400), pageObjects: [TextObject(), ImageObject()])
        project.pages[0].pageObjects = [TextObject(), ImageObject(), group]
        
        return project
    }
}

extension PageObjectContainer {
    subscript<T: PageObject> (at index: Int, asType type: T.Type) -> T? {
        get {
            pageObjects[index] as? T
        }
        set {
            if let value = newValue {
                pageObjects[index] = value
            }
        }
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
