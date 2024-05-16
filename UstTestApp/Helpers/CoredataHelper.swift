
import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    let persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "UstTestApp")
    
    init() {
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchAirPlayDevices() -> [AirPlayDevice]? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Device")
        
        do {
            let context = persistentContainer.viewContext
            let result = try context.fetch(fetchRequest)
            var devices = [AirPlayDevice]()
            
            for data in result as! [NSManagedObject] {
                if let name = data.value(forKey: "name") as? String,
                   let ipAddress = data.value(forKey: "ipAddress") as? String,
                   let isReachable = data.value(forKey: "isReachable") as? Bool {
                    let device = AirPlayDevice(name: name, ipAddress: ipAddress, isReachable: isReachable)
                    devices.append(device)
                }
            }
            
            return devices
        } catch {
            print("Failed to fetch AirPlay devices: \(error)")
            return nil
        }
    }
    
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func entityExists(entityName: String, with predicate: NSPredicate? = nil) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if entity exists: \(error)")
            return false
        }
    }
    
    func saveNewAirPlayDevice(device: AirPlayDevice) {
        let context = persistentContainer.viewContext
        let newDevice = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context)
        newDevice.setValue(device.name, forKey: "name")
        newDevice.setValue(device.ipAddress, forKey: "ipAddress")
        newDevice.setValue(device.isReachable, forKey: "isReachable")
        saveContext()
    }
    
    func deleteAirPlayDevice(device: AirPlayDevice) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Device")
        fetchRequest.predicate = NSPredicate(format: "name == %@", device.name)
        
        do {
            let result = try context.fetch(fetchRequest)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            saveContext()
        } catch {
            print("Failed to delete AirPlay device: \(error)")
        }
    }
    
    func getCountOfAirPlayDevices() -> Int {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Device")
        
        do {
            let context = persistentContainer.viewContext
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Failed to get count of devices: \(error)")
            return 0
        }
    }
}
