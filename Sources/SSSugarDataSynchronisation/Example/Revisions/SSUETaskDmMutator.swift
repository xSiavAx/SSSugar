import Foundation

/// Task Mutator working with Data Modifications (based on revisions).
///
/// For each Task mutation – mutate data via super's `mutate` (see docs).
///
/// # Requires:
/// * some `SSMutatingEntitySource` with `SSUETask` as `Entity`
/// * some `SSDmRequestDispatcher` with `SSModify` as `Request`
///
/// # Extends:
/// `SSEntityDmMutator`
///
/// # Conforms to:
/// `SSUETaskMutator`
internal class SSUETaskDmMutator<Source: SSMutatingEntitySource, Dispatcher: SSDmRequestDispatcher>: SSEntityDmMutator<Source, Dispatcher>
where Source.Entity == SSUETask, Dispatcher.Request == SSModify {
    typealias Request = Dispatcher.Request
    
    private func mutateTask(job: @escaping (_ task: SSUETask) throws -> [Request], handler:
        @escaping (_ error: Error?)->Void) {
        if let task = source?.entity(for: self) {
            do {
                mutate(requests: try job(task), handler: handler)
            } catch {
                onMain { handler(error) }
            }
        } else {
            onMain { handler(nil) }
        }
    }
}

extension SSUETaskDmMutator: SSUETaskMutator {
    func increment(_ handler: @escaping (Error?) -> Void) {
        func job(task: SSUETask) -> [Request] {
            return [SSUETaskIncrementPagesRequest(taskID: task.taskID)]
        }
        mutateTask(job: job(task:), handler: handler)
    }
    
    func rename(new name: String, _ handler: @escaping (Error?) -> Void) {
        func job(task: SSUETask) -> [Request] {
            return [SSUETaskRenameRequest(taskID: task.taskID, taskTitle: name)]
        }
        mutateTask(job: job(task:), handler: handler)
    }
    
    func remove(_ handler: @escaping (Error?) -> Void) {
        func job(task: SSUETask) -> [Request] {
            return [SSUETaskRemoveRequest(taskID: task.taskID)]
        }
        mutateTask(job: job(task:), handler: handler)
    }
}
