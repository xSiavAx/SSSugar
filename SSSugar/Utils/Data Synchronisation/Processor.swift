import Foundation

/// Struct incapsulate data obtain result.
public struct SSObtainResult<Model> {
    /// Indicate should obtaining be repeated or not. For example, if obtainer decide that data may be not actual it return result with 'true' value in this property.
    public var needReobtain = false
    /// Obtaining model
    public var model : Model?
    
    public init() {}
}

/// Protocol with requirements for each model obtainer.
public protocol SSModelObtainer {
    /// Obtaining model type
    associatedtype Model
    typealias Result = SSObtainResult<Model>
    
    /// Prepare to obtain model (for example, notification subscriptions)
    ///
    /// - Note: Obtainer will not remove. So you can repeat obtaining at some point in future.
    func start()
    /// Obtain model
    func obtain()
    /// Generate obtaining result
    func finish() -> Result
}

/// Protocol with requieremnts for model obtainer that can recieve model notifications and react on em.
/// There are default implementations for `start` and zfinish` methods.
public protocol SSUpdatingModelObtainer: SSModelObtainer, SSUpdateReceiver {
    /// Center to subscribe on and send notifications
    var updateCenter: SSUpdateCenter {get}
    
    /// Obtaining result
    ///
    /// - Warning: Don't create/clear it's on your own. `SSUpdatingModelObtainer` extension will do it in `start` and `finish` methods
    var result: Result? {get set}
}

public extension SSUpdatingModelObtainer {
    func start() {
        result = Result()
        updateCenter.addReceiver(self)
    }
    
    func finish() -> Result {
        defer {
            result = nil
        }
        updateCenter.removeReceiver(self)
        return result!
    }
    
    func markNeedReobtain() {
        result?.needReobtain = true
    }
    
    func onModelRemove() {
        result?.model = nil
        result?.needReobtain = false
    }
}

public protocol SSModelGetter {
    associatedtype Model
    func get() -> Model?
}

public protocol SSUpdatingModelGetObtainer: SSUpdatingModelObtainer {
    associatedtype Getter: SSModelGetter
    
    var getter: Getter {get}
}

extension SSUpdatingModelGetObtainer where Getter.Model == Model {
    public func obtain() {
        result?.model = getter.get()
    }
}

open class SSUpdatingObtainer<SModelGetter: SSModelGetter>: SSUpdatingModelGetObtainer {
    public typealias Model = SModelGetter.Model
    
    public var updateCenter: SSUpdateCenter
    public var result: SSObtainResult<Model>?
    public var getter: SModelGetter
    
    public init(updater: SSUpdateCenter, modelGetter: SModelGetter) {
        updateCenter = updater
        getter = modelGetter
    }
    
    deinit {
        updateCenter.removeReceiver(self)
    }

    /// Dummy reactions implementation. Each inheritor has override this method.
    ///
    /// - Returns: empty reactions dict.
    public func reactions() -> SSUpdate.ReactionMap { return [:] }
}


/// Base class for Any Model Processor. Incapsulate obtain and updates subscribtions logic.
///
/// There is ModelObtainer as Generic.
open class SSModelProcessor<Obtainer: SSModelObtainer> {
    /// Internal struct implementing ObtainJob protocol
    private struct ProcObtainJob: SSObtainJob {
        let run: ()->Void
        let onFinish: ()->Bool
    }
    /// Struct implementing EditJob protocol
    public struct ProcEditJob: SSProcessorJob {
        public let run: () throws ->Void
        public let onFinish: ()->Void
        
        public init(run mRun: @escaping () throws ->Void, onFinish mOnFinish: @escaping ()->Void) {
            run = mRun
            onFinish = mOnFinish
        }
    }
    /// Model Processor work with
    public typealias Model = Obtainer.Model
    
    /// Processor's model obtainer
    public private(set) var obtainer: Obtainer?
    /// Update center for notification subscriptions
    public let updater: SSUpdateCenter
    /// Processor's model.
    /// - Warning: This is protected property, don't call it settet outside the class or it inheritor.
    public var pModel: Model?
    
    /// Create new processor with passed Update Center and Obtainer
    ///
    /// Ussually inheritor creates Obtainer and pass it to super's init
    /// - Parameters:
    ///   - updater: Update Center for notificatons subscriptions
    ///   - obtainer: Model obtainer
    public init(updater mUpdater: SSUpdateCenter, obtainer mObtainer: Obtainer) {
        updater = mUpdater
        obtainer = mObtainer
    }
    
    deinit { updater.removeReceiver(self) }
    
    //MARK: protected
    /// Calls on model did obtain and assign, but before update receiver will adds
    ///
    /// - Note: Override this method if you need additional actions at this point
    open func pModelDidAssign() {}
    
    /// Calls on no model did obtain
    ///
    /// - Note: Override this method if you need additional actions at this point
    open func pModelUnavailable() {}
}

extension SSModelProcessor: SSObtainJobCreator {
    /// Obtain data. Creates Obtain Job object user can control obtaining process with.
    ///
    /// - Returns: created ObtainJob object.
    public func obtain() -> SSObtainJob {
        obtainer!.start()
        return ProcObtainJob(run: obtainer!.obtain, onFinish: onDidObtain)
    }
    
    //MARK: private
    private func onDidObtain() -> Bool {
        guard let data = obtainer?.finish() else { fatalError("Invalid state") }
        guard !data.needReobtain else { return false }
        
        if let model = data.model {
            assign(model: model)
        } else {
            pModelUnavailable()
        }
        return true
    }
    
    /// Clear obtainer, assign model, notify delegate and add Update Receiver
    ///
    /// - Parameter model: model to assign
    private func assign(model: Model) {
        obtainer = nil
        pModel = model
        pModelDidAssign()
        updater.addReceiver(self)
    }
}

extension SSModelProcessor: SSUpdateReceiver {
    /// Dummy reactions implementation. Each inheritor has override this method.
    ///
    /// - Returns: empty reactions dict.
    public func reactions() -> SSUpdate.ReactionMap {
        return [:]
    }
}
