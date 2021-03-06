//
//  CoreData2.swift
//  LPC Wearable Toolkit
//
//  Created by Bridget Murphy on 7/11/18.
//  Copyright © 2018 Varun Narayanswamy LPC. All rights reserved.
//
import UIKit
import CoreData

class Accelerations {
    
    var managedAccelerations: [Acceleration] = []
    var minTimestamp:Double!
    var maxTimestamp:Double!
    
    init() {
        managedAccelerations = fetchAll()
        minTimestamp = managedAccelerations.min(by: {acc1, acc2 in acc1.timestamp < acc2.timestamp})?.timestamp
        maxTimestamp = managedAccelerations.max(by: {acc1, acc2 in acc1.timestamp < acc2.timestamp})?.timestamp
    }
    
    func countAll(sport: String) -> Int {
        return fetch(sport: sport).count
    }
    
    func getMinTimestamp() -> Double {
        return minTimestamp
    }
    
    func getMaxTimestamp() -> Double {
        return maxTimestamp
    }
    
    func fetchAll() -> [Acceleration] {
        var fetchedAccelerations: [Acceleration] = []
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Acceleration")
        
        //3
        do {
            fetchedAccelerations = try managedContext.fetch(fetchRequest) as? [Acceleration] ?? []
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return fetchedAccelerations
    }
    
    func fetch(sport: String, start_ts: Double, stop_ts: Double) -> [Acceleration] {
        var accelerations: [Acceleration] = []
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Acceleration")
        
        let sportPredicate = NSPredicate(format: "sport = %@ && ( timestamp >= \(start_ts) && timestamp <= \(stop_ts))", sport) // This is apparently not safe
        fetchRequest.predicate = sportPredicate
        
        let sort = NSSortDescriptor(key: #keyPath(Acceleration.timestamp), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        //3
        do {
            accelerations = try managedContext.fetch(fetchRequest) as? [Acceleration] ?? []
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return accelerations
    }
    
    func fetch(sport: String) -> [Acceleration] {
        var accelerations: [Acceleration] = []
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Acceleration")
        
        let sportPredicate = NSPredicate(format: "sport = %@", sport)
        fetchRequest.predicate = sportPredicate
        
        let sort = NSSortDescriptor(key: #keyPath(Acceleration.timestamp), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        //3
        do {
            accelerations = try managedContext.fetch(fetchRequest) as? [Acceleration] ?? []
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return accelerations
    }
    
    //
    func save(x: Double, y: Double, z: Double, timestamp: Double, sport: String) -> Acceleration? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Acceleration",
                                       in: managedContext)!
        
        let acceleration = Acceleration(entity: entity, insertInto: managedContext)
        
        // 3
        
        acceleration.setValue(x, forKeyPath: "xAcceleration")
        acceleration.setValue(y, forKeyPath: "yAcceleration")
        acceleration.setValue(z, forKeyPath: "zAcceleration")
        acceleration.setValue(sport, forKey: "sport")
        acceleration.setValue(timestamp, forKey: "timestamp")

        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return acceleration
    }
    
    func deleteAllData(entity: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}


