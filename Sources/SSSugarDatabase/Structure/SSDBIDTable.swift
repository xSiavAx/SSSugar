import Foundation

public protocol SSDBIDTable: SSDBTable {
    associatedtype IDColumn: SSDBTypedColumnProtocol
    
    static var idColumn: IDColumn { get }
    
    static var idLessColumns: [SSDBColumnProtocol] { get }
}

//MARK: - SSDBTable

public extension SSDBIDTable {
    static var primaryKey: SSDBPrimaryKeyProtocol? { pk(idColumn) }
    
    static var colums: [SSDBColumnProtocol] { [idColumn] + idLessColumns }
    
    static func remove() -> SSDBQueryProcessor<IDColumn.ColType, Void> {
        return SSDBQueryProcessor(removeQuery(), onBind: { try $0.bind($1) })
    }
}

//MARK: - Reference Creating

public extension SSDBIDTable {
    static func idRef(for table: SSDBTable.Type, prefix: String? = nil, optional: Bool? = nil) -> SSDBColumnRef<IDColumn> {
        return SSDBColumnRef(table, prefix: prefix, optional: optional, col: idColumn)
    }
}

//MARK: - Queries

public extension SSDBIDTable {
    // Query for inserting row with every table colums except id
    static func saveQuery() -> String {
        insertQuery(cols: idLessColumns)
    }
    
    static func updateQuery() -> String {
        return updateQuery(cols: idLessColumns)
    }
}
