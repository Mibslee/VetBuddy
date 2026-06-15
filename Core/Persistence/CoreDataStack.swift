import CoreData

// MARK: - Managed Object Subclasses

@objc(AssessmentMO)
final class AssessmentMO: NSManagedObject, @unchecked Sendable {
    @NSManaged var date: Date
    @NSManaged var riskLevel: String
    @NSManaged var fitnessLevel: String
    @NSManaged var answers: Data
}

@objc(DailyPlanMO)
final class DailyPlanMO: NSManagedObject, @unchecked Sendable {
    @NSManaged var date: Date
    @NSManaged var exercises: Data
    @NSManaged var targetDuration: Int32
    @NSManaged var isCompleted: Bool
}

@objc(TrainingRecordMO)
final class TrainingRecordMO: NSManagedObject, @unchecked Sendable {
    @NSManaged var date: Date
    @NSManaged var exerciseId: String
    @NSManaged var completedSets: Int32
    @NSManaged var completedReps: Int32
    @NSManaged var duration: Double
    @NSManaged var notes: String?
}

@objc(HealthSnapshotMO)
final class HealthSnapshotMO: NSManagedObject, @unchecked Sendable {
    @NSManaged var date: Date
    @NSManaged var steps: Int32
    @NSManaged var heartRate: Double
    @NSManaged var weight: Double
}

// MARK: - Core Data Stack

final class CoreDataStack: ObservableObject, @unchecked Sendable {

    static let shared = CoreDataStack()

    private let inMemory: Bool

    private(set) lazy var container: NSPersistentContainer = {
        let model = Self.buildModel()
        let container = NSPersistentContainer(name: "VetBuddy", managedObjectModel: model)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }

    // MARK: - Background Context

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func performBackgroundTask(_ block: @escaping @Sendable (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
        }
    }

    // MARK: - Save

    func save(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - Fetch

    func fetch<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        fetchLimit: Int = 0,
        context: NSManagedObjectContext? = nil
    ) -> [T] {
        let ctx = context ?? viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if fetchLimit > 0 {
            request.fetchLimit = fetchLimit
        }
        do {
            return try ctx.fetch(request) as? [T] ?? []
        } catch {
            let nsError = error as NSError
            assertionFailure("Core Data fetch error: \(nsError), \(nsError.userInfo)")
            return []
        }
    }

    // MARK: - Programmatic Model

    private static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // AssessmentMO
        let assessmentEntity = NSEntityDescription()
        assessmentEntity.name = String(describing: AssessmentMO.self)
        assessmentEntity.managedObjectClassName = String(describing: AssessmentMO.self)
        assessmentEntity.properties = [
            attribute("date", .dateAttributeType),
            attribute("riskLevel", .stringAttributeType),
            attribute("fitnessLevel", .stringAttributeType),
            attribute("answers", .transformableAttributeType),
        ]
        model.entities.append(assessmentEntity)

        // DailyPlanMO
        let dailyPlanEntity = NSEntityDescription()
        dailyPlanEntity.name = String(describing: DailyPlanMO.self)
        dailyPlanEntity.managedObjectClassName = String(describing: DailyPlanMO.self)
        dailyPlanEntity.properties = [
            attribute("date", .dateAttributeType),
            attribute("exercises", .transformableAttributeType),
            attribute("targetDuration", .integer32AttributeType),
            attribute("isCompleted", .booleanAttributeType),
        ]
        model.entities.append(dailyPlanEntity)

        // TrainingRecordMO
        let trainingRecordEntity = NSEntityDescription()
        trainingRecordEntity.name = String(describing: TrainingRecordMO.self)
        trainingRecordEntity.managedObjectClassName = String(describing: TrainingRecordMO.self)
        let notesAttr = attribute("notes", .stringAttributeType)
        notesAttr.isOptional = true
        trainingRecordEntity.properties = [
            attribute("date", .dateAttributeType),
            attribute("exerciseId", .stringAttributeType),
            attribute("completedSets", .integer32AttributeType),
            attribute("completedReps", .integer32AttributeType),
            attribute("duration", .doubleAttributeType),
            notesAttr,
        ]
        model.entities.append(trainingRecordEntity)

        // HealthSnapshotMO
        let healthSnapshotEntity = NSEntityDescription()
        healthSnapshotEntity.name = String(describing: HealthSnapshotMO.self)
        healthSnapshotEntity.managedObjectClassName = String(describing: HealthSnapshotMO.self)
        healthSnapshotEntity.properties = [
            attribute("date", .dateAttributeType),
            attribute("steps", .integer32AttributeType),
            attribute("heartRate", .doubleAttributeType),
            attribute("weight", .doubleAttributeType),
        ]
        model.entities.append(healthSnapshotEntity)

        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        return attr
    }

    // MARK: - Preview (In-Memory)

    static let preview = CoreDataStack(inMemory: true)
}
