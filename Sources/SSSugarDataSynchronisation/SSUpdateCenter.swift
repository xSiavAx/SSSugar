import Foundation
import SSSugarExecutors

#warning("Race condition")
//TODO: It's reace condition on add/remove observer. Add usually calls from BG queue. Remove may be called within `deinit` from main queue.

/// Updater protocol with requierement to managing receivers
public protocol SSUpdateReceiversManaging {
    /// Start sending notofications for passed listeners
    ///
    /// - Parameter receiver: Receiver to add
    func addReceiver(_ receiver: SSUpdateReceiver)
    
    /// Stop sending notofications for passed listeners
    ///
    /// - Parameter receiver: Receiver for remove
    func removeReceiver(_ receiver: SSUpdateReceiver)
}

/// Updater protocol with requierement to notifying
public protocol SSUpdateNotifier {
    /// Send passed update to all listeners that wait for it
    /// - Parameters:
    ///   - update: Update to send
    ///   - onApply: Finish handler
    func notify(update: SSUpdate, onApply:(()->Void)?)
        
    
    /// Send passed updates to all listeners that wait for them
    /// - Parameters:
    ///   - updates: Updates to send
    ///   - onApply: Finish handler
    func notify(updates: [SSUpdate], onApply:(()->Void)?)
}

extension SSUpdateNotifier {
    public func notify(update: SSUpdate, onApply:(()->Void)? = nil) {
        notify(updates: [update], onApply: onApply)
    }
}

/// Requirements for Update Center tool. Composition of `SSUpdateReceiversManaging` and `SSUpdateNotifier`.
public protocol SSUpdateCenter: SSUpdateReceiversManaging, SSUpdateNotifier {}

/// Concreate Update Center implementation that use SDK's Notification Center inside.
public class SSUpdater: SSUpdateCenter, SSOnMainExecutor {
    /// Internal class for simplyfy Update Center code.
    class Observer {
        var tokens : [AnyObject]?
        var receiver : SSUpdateReceiver
        var converter : UpdatesConverter
        
        init(receiver mReceiver: SSUpdateReceiver, converter mConverter: UpdatesConverter) {
            receiver = mReceiver
            converter = mConverter
        }
    }
    class UpdatesConverter {
        let prefix: String?
        
        init(prefix mPrefix: String?) {
            prefix = mPrefix
        }
    }
    private var converter: UpdatesConverter
    private var observers = [Observer]()
    
    /// Creates new Updater instance.
    /// - Parameter withIdentifier: Updater identifier. Updaters with different identifiers works with their own's notifications pool. In case updaters has equal identifiers – notification posted via one will be recieved by UpdateReceiver's of another updater.
    ///
    /// Due to implementation using NotificationCenter, all updaters work in common notifications poll. This identifier may be used to separate notifications for different update centers (cuz it adds as prefix to notifications name). Its especially usefull for tests.
    public init(withIdentifier: String? = nil) {
        converter = UpdatesConverter(prefix: withIdentifier)
    }
}

extension SSUpdater: SSUpdateReceiversManaging {
    //MARK: SSUpdateReceiversManaging
    public func addReceiver(_ receiver: SSUpdateReceiver) {
        let observer = Observer(receiver: receiver, converter: converter)
        
        observer.startObserving()
        observers.append(observer)
    }
    
    public func removeReceiver(_ receiver: SSUpdateReceiver) {
        observers.removeAll() {
            if ($0.receiver === receiver) {
                $0.stopObserving()
                return true
            }
            return false
        }
    }
}

extension SSUpdater: SSUpdateNotifier {
    //MARK: SSUpdateNotifier
    
    /// Send passed updates to all listeners that subscribed on 'em.
    ///
    /// For each update calls reaction methods of each Receiver to let receivers obtain additional data (if needed) and collect modifications. Then call `apply()` for each receiver on Main Queue.
    /// - Parameters:
    ///   - updates: Updates to send
    ///   - onApply: Finish handler
    public func notify(updates: [SSUpdate], onApply: (() -> Void)?) {
        notifications(from:updates).forEach(post(_:))
        onMain {[weak self] in
            self?.observers.forEach { $0.receiver.apply() }
            onApply?()
        }
    }
    
    private func notifications(from updates: [SSUpdate]) -> [Notification] {
        return updates.map { converter.notification(from: $0) }
    }
    
    private func post(_ notification: Notification) {
        NotificationCenter.default.post(notification)
    }
}

extension SSUpdater.UpdatesConverter {
    private static let markerKey = "notification_marker"
    private static let argsKey = "notification_args"
    
    func info(from notification: Notification) -> SSUpdate {
        guard let userInfo = notification.userInfo else {
            fatalError("Invalid notification")
        }
        let name = updateName(fromNotificationName: notification.name)
        let marker = userInfo[Self.markerKey] as! String
        let args = userInfo[Self.argsKey] as! [AnyHashable : Any]
        
        return SSUpdate(name: name, marker: marker, args: args)
    }

    func notification(from update: SSUpdate) -> Notification {
        let notName = notificationName(withUpdateName: update.name)
        let userInfo = [Self.markerKey : update.marker, Self.argsKey : update.args] as [AnyHashable : Any]
        return Notification(name: notName, object: nil, userInfo: userInfo)
    }
    
    func notificationName(withUpdateName name: String) -> Notification.Name {
        if let mPrefix = prefix {
            return Notification.Name("\(mPrefix)_\(name)")
        }
        return Notification.Name(name)
    }
    
    private func updateName(fromNotificationName name: Notification.Name) -> String {
        if let mPrefix = prefix {
            return String(name.rawValue.dropFirst(mPrefix.count + 1))
        }
        return name.rawValue
    }
}

extension SSUpdater.Observer {
    /// Register receiver's reactions in Notification Center
    func startObserving() {
        tokens = receiver.reactions().map(register)
    }
    
    /// Unregister receiver's reactions from Notification Center
    func stopObserving() {
        guard let mTokens = tokens else { fatalError("Observer wasn't started") }
        for token in mTokens { NotificationCenter.default.removeObserver(token) }
        tokens = nil
    }
    
    //MARK: private
    private func register(name: String, reaction: @escaping SSUpdate.Reaction) -> AnyObject {
        func process(notification: Notification) {
            reaction(converter.info(from: notification))
        }
        let token = NotificationCenter.default.addObserver(forName: converter.notificationName(withUpdateName: name),
                                                           object: nil,
                                                           queue: nil,
                                                           using: process(notification:))
        return token
    }
}
