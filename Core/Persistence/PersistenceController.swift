import CoreData

/// Higher-level persistence operations built on top of CoreDataStack.
struct PersistenceController: @unchecked Sendable {

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    // MARK: - Create

    func create<T: NSManagedObject>(
        entityName: String,
        configure: (T) -> Void,
        context: NSManagedObjectContext? = nil
    ) -> T {
        let ctx = context ?? stack.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: ctx) else {
            fatalError("Entity \(entityName) not found in managed object model")
        }
        let object = T(entity: entity, insertInto: ctx)
        configure(object)
        stack.save(context: ctx)
        return object
    }

    // MARK: - Fetch

    func fetch<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        fetchLimit: Int = 0,
        context: NSManagedObjectContext? = nil
    ) -> [T] {
        stack.fetch(
            entityName: entityName,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            fetchLimit: fetchLimit,
            context: context
        )
    }

    // MARK: - Update

    func update<T: NSManagedObject>(
        _ object: T,
        configure: (T) -> Void,
        context: NSManagedObjectContext? = nil
    ) {
        configure(object)
        stack.save(context: context)
    }

    // MARK: - Delete

    func delete(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        let ctx = context ?? stack.viewContext
        ctx.delete(object)
        stack.save(context: ctx)
    }

    func batchDelete(
        entityName: String,
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) {
        let ctx = context ?? stack.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchRequest.resultType = .resultTypeObjectIDs

        do {
            guard let result = try ctx.execute(batchRequest) as? NSBatchDeleteResult,
                  let objectIDs = result.result as? [NSManagedObjectID] else {
                return
            }
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [ctx])
        } catch {
            let nsError = error as NSError
            assertionFailure("Batch delete error: \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - Date-Range Queries

    func fetchInRange<T: NSManagedObject>(
        entityName: String,
        dateKey: String = "date",
        from: Date,
        to: Date,
        sortDescriptors: [NSSortDescriptor] = [],
        context: NSManagedObjectContext? = nil
    ) -> [T] {
        let predicate = NSPredicate(
            format: "%K >= %@ AND %K <= %@",
            dateKey, from as NSDate,
            dateKey, to as NSDate
        )
        return fetch(
            entityName: entityName,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            context: context
        )
    }

    // MARK: - Count

    func count(
        entityName: String,
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) -> Int {
        let ctx = context ?? stack.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = predicate
        do {
            return try ctx.count(for: request)
        } catch {
            let nsError = error as NSError
            assertionFailure("Core Data count error: \(nsError), \(nsError.userInfo)")
            return 0
        }
    }
}
