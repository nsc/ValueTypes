import XCTest
@testable import ValueTypes

final class ValueTypesTests: XCTestCase {
    func testExample() throws {
        var project = makeProject()
        
        // Shift all objects inside of a group on some page
        for i in 0..<project.pages.count {
            var page = project.pages[i]
            
            for j in 0..<page.pageObjects.count {
                let pageObject = page.pageObjects[j]
            
                if var group = pageObject as? Group {
                    for k in 0..<group.pageObjects.count {
                        var pageObject = group.pageObjects[k]
                        
                        let shiftedFrame = pageObject.frame.applying(CGAffineTransform(translationX: 10, y: 10))
                        pageObject.frame = shiftedFrame
                        
                        // Write back changed page object
                        group.pageObjects[k] = pageObject
                    }
                
                    // Write back changed group
                    page.pageObjects[j] = group
                }
            }
            
            // Write back changed page
            project.pages[i] = page
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
