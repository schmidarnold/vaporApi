import FluentMySQL
import Foundation

final class AcronymCategoryPivot: MySQLPivot,ModifiablePivot {
    var id: Int?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronym: Acronym, _ category: Category) throws {
        self.acronymID = try acronym.requireID()
        self.categoryID = try category.requireID()
    }
    
    
}
extension AcronymCategoryPivot: Migration{}
