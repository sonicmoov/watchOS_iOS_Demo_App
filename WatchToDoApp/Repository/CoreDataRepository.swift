//
//  MainCoreDataRepository.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/13.
//

import UIKit
import CoreData


class CoreDataRepository {
    
    private static let persistentName = "WatchToDoApp"
    
    private static var persistenceController: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataRepository.persistentName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
        
    
    public static var context: NSManagedObjectContext {
        return CoreDataRepository.persistenceController.viewContext
    }

}

// MARK: - Create
extension CoreDataRepository {
    
    /// 新規作成
    public static func newEntity<T: NSManagedObject>() -> T {
        let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context)!
        return T(entity: entity, insertInto: context)
    }
}

// MARK: - Insert/Update/Delete
extension CoreDataRepository {

    /// 追加処理
    public static func insert(_ object: NSManagedObject) {
        context.insert(object)
        saveContext()
    }
    
    /// 削除処理
    public static func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }
}


// MARK: - Save
extension CoreDataRepository {
    /// Contextに応じたSave
    public static func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}


// MARK: - 取得
extension CoreDataRepository {
    
    public static func fetch<T: NSManagedObject>() -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    public static func fetchSingle<T: NSManagedObject>(predicate: NSPredicate? = nil, sorts: [NSSortDescriptor]? = nil) -> T {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        // フィルタリング
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        var result: T!
        // ソート
        if let sorts = sorts {
            fetchRequest.sortDescriptors = sorts
        }
        
        do {
            let entitys = try context.fetch(fetchRequest)
            if let entity = entitys.first {
                result = entity
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return result
    }
    
    public static func deleteAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Work.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to delete data for entity \(error)")
        }
    }

}
