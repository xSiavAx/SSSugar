import Foundation

public protocol SSDataBaseBindingStatement {
    func bind(int: Int, pos: Int)
    func bind(int: Int?, pos: Int)
    
    func bind(int64: Int64, pos: Int)
    func bind(int64: Int64?, pos: Int)
    
    func bind(double: Double, pos: Int)
    func bind(double: Double?, pos: Int)
    
    func bind(string: String, pos: Int)
    func bind(string: String?, pos: Int)
    
    func bind(data: Data, pos: Int)
    func bind(data: Data?, pos: Int)
    
    func bindNull(pos: Int)
}

public protocol SSDataBaseGettingStatement {
    func getInt(pos: Int) -> Int
    func getIntOp(pos: Int) -> Int?
    
    func getInt64(pos: Int) -> Int64
    func getInt64Op(pos: Int) -> Int64?
    
    func getDouble(pos: Int) -> Double
    func getDoubleOp(pos: Int) -> Double?
    
    func getString(pos: Int) -> String?
    func getData(pos: Int) -> Data?
}

public protocol SSDataBaseStatementProtocol: SSDataBaseBindingStatement, SSDataBaseGettingStatement, SSReleasable {
    func select() -> Bool
    func commit() throws
    func clear()
}

public protocol SSDataBaseSavePointProtocol: SSReleasable {
    func rollBack() throws
}

public protocol SSDataBaseStatementCreator: AnyObject {
    func statement(forQuery : String) throws -> SSDataBaseStatementProtocol
}

public protocol SSDataBaseProtocol: SSTransacted, SSDataBaseStatementCreator, SSDataBaseQueryExecutor, SSCacheContainer {
    func savePoint(withTitle: String) throws -> SSDataBaseSavePointProtocol
}
