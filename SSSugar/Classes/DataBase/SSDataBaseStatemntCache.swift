import Foundation

protocol SSDataBaseStatementCacheProtocol {
    func statement(query: String) -> SSDataBaseStatementProtocol
    func clearOld()
    func clearOlderThen(interval: TimeInterval)
    func clearAll() throws
}

class SSDataBaseStatementCache {
    static let kDefaultLifeTime : TimeInterval = 60.0
    
    enum mError: Error {
        case statementsAreInUse
    }
    
    let lifeTime : TimeInterval
    unowned var creator : SSDataBaseStatementCreator
    private var holders = AutoMap<String, [SSDataBaseStatementCacheHolder]>()
    
    init(lifeTime mLifeTime: TimeInterval = SSDataBaseStatementCache.kDefaultLifeTime, statementsCreator: SSDataBaseStatementCreator) {
        lifeTime = mLifeTime
        creator = statementsCreator
    }
}

//MARK: - SSDataBaseStatementCacheProtocol

extension SSDataBaseStatementCache: SSDataBaseStatementCacheProtocol {
    func statement(query: String) -> SSDataBaseStatementProtocol {
        let holder = cachedHolderByQuery(query) ?? createHolderForQuery(query)
        
        return SSDataBaseStatementReleaseDecorator(statement: holder.statement, onCreate: { [unowned self] (stmt) in
            self.occupyHolder(holder)
        }, onRelease: { [unowned self] (stmt) in
            self.releaseHolder(holder)
        })
        
    }
    
    func clearOld() {
        clearOlderThen(interval: lifeTime)
    }
    
    func clearOlderThen(interval: TimeInterval) {
        var indexes = AutoMap<String, [Int]>()
        
        for query in holders.keys {
            for (idx, holder) in holders[query]!.enumerated() {
                if (!holder.occupied && holder.olderThen(age: interval)) {
                    indexes.add(idx, for: query)
                    holder.statement.release()
                }
            }
        }
        if (!indexes.isEmpty) {
            holders.remove(forKeyAndIndexes: indexes)
        }
    }
    
    func clearAll() throws {
        for (_, _, holder) in holders {
            guard !holder.occupied else {
                throw mError.statementsAreInUse
            }
            holder.statement.release()
        }
        holders.removeAll()
    }
    
    //MARK: private
    private func cachedHolderByQuery(_ query: String) -> SSDataBaseStatementCacheHolder? {
        if let queryHolders = holders[query] {
            for i in queryHolders.count-1...0 {
                if (!queryHolders[i].occupied) {
                    return queryHolders[i]
                }
            }
        }
        return nil
    }
    
    private func createHolderForQuery(_ query: String) -> SSDataBaseStatementCacheHolder {
        let holder = SSDataBaseStatementCacheHolder(stmt: creator.statement(forQuery: query))
        
        holders.add(holder, for: query)
        return holder
    }
    
    private func occupyHolder(_ holder: SSDataBaseStatementCacheHolder) {
        do {
            try holder.occupy()
        } catch SSDataBaseStatementCacheHolder.mError.alreadyOccupied {
            fatalError("Holder already occupied")
        } catch {
            fatalError("Unexpected error on occupy holder \(error)")
        }
    }
    
    private func releaseHolder(_ holder: SSDataBaseStatementCacheHolder) {
        do {
            try holder.release()
        } catch SSDataBaseStatementCacheHolder.mError.notOccupied {
            fatalError("Holder not occupied")
        } catch {
            fatalError("Unexpected error on occupy holder \(error)")
        }
    }
}
