//
//  ControlData.swift
//  LocationWeather
//
//  Created by Noel Obaseki on 17/07/2020.
//


import Foundation
import UIKit
import CoreData

class ControlData {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()->Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    static func shared() -> ControlData {
        struct Singleton {
            static var shared = ControlData(modelName: "LocationWeather")
        }
        return Singleton.shared
    }
}

