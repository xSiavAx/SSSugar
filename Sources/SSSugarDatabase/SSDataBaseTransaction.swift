import Foundation

public protocol SSDataBaseQueryExecutor : AnyObject {
    func exec(query: String) throws
}

public class SSDataBaseTransaction {
    public unowned let executor : SSDataBaseQueryExecutor
    private var closed: Bool
    
    public enum mError: Error {
        case alreadyClosed
    }
    
    public init(executor mExecutor: SSDataBaseQueryExecutor) throws {
        executor = mExecutor
        try executor.exec(query: "begin transaction;")
        closed = false
    }
    
    deinit {
        guard closed else {
            fatalError("Transaction hasn't been closed.")
        }
    }
    
    //MARK: - public
    public func commit() throws {
        try ensureOpen()
        try executor.exec(query:"commit transaction;")
        closed = true
    }
    
    public func cancel() throws {
        try ensureOpen()
        try executor.exec(query:"rollback transaction;")
        closed = true
    }
    
    //MARK: - private
    private func ensureOpen() throws {
        guard !closed else {
            throw mError.alreadyClosed
        }
    }
}
