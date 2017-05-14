//
//  ImageLoader.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 11.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit

class DataLoader {
    
    private static var imageCache = [String: UIImage]()
    private static var otherDataCache = [String: Any]()
    private static var imgCacheIsLoaded = false
    private static var dataCacheIsLoaded = false
    
    public static func saveImgCache() {
        print("saving image cache")
        var dataToSave = [String: Data]()
        imageCache.forEach({ (key: String, image: UIImage) -> Void in
            dataToSave[key] = NSKeyedArchiver.archivedData(
                withRootObject: UIImagePNGRepresentation(image)!
            )
        })
        UserDefaults.standard.setValue(
            dataToSave,
            forKey: "imageCache"
        )
        UserDefaults.standard.synchronize()
        imgCacheIsLoaded = true
        print("saved image cache!!!")
    }
    
    public static func saveDataCache() {
        print("saving data cache")
        UserDefaults.standard.setValue(
            otherDataCache as NSDictionary,
            forKey: "otherDataCache"
        )
        UserDefaults.standard.synchronize()
        dataCacheIsLoaded = true
        print("saved data cache!!!")
    }
    
    public static func loadImgCache() {
        if (!imgCacheIsLoaded) {
            let rowImageCache = UserDefaults.standard.value(
                forKey: "imageCache"
            ) as? [String: Data] ?? [:]
            rowImageCache.forEach({ (key: String, value: Data) -> () in
                imageCache[key] = UIImage(data: value)
            })
            imgCacheIsLoaded = true
        }
    }
    
    public static func loadDataCache() {
        if (!dataCacheIsLoaded) {
            otherDataCache = UserDefaults.standard.value(
                forKey: "otherDataCache"
            ) as? [String: Any] ?? [:]
            dataCacheIsLoaded = true
        }
    }
    
    
    public static func resetImageCache() {
        imgCacheIsLoaded = true
        imageCache = [:]
        saveImgCache()
    }
    
    public static func resetOtherDataCache() {
        dataCacheIsLoaded = true
        otherDataCache = [:]
        saveDataCache()
    }
    
    public static func loadImage(byUrl url: String, postAction: @escaping (UIImage) -> () = {_ in }) {
        loadImgCache()
        if let cachedImage = imageCache[url] {
            DispatchQueue.main.async {
                postAction(cachedImage)
            }
        } else {
            let task = URLSession.shared.dataTask(
                with: URL(string: url)!
            ) { (responseData, responseUrl, error) -> () in
                DispatchQueue.main.async(execute: { () -> Void in
                    var loadedImage = #imageLiteral(resourceName: "StepikLogo")
                    if let data = responseData {
                        loadedImage = UIImage(data: data) ?? #imageLiteral(resourceName: "StepikLogo")
                    }
                    DataLoader.imageCache[url] = loadedImage
                    postAction(loadedImage)
                })
            }
            task.resume()
        }
    }
    
    public static func getCachedData(by key: String, postAction: @escaping () -> () = {}) -> Any? {
        loadDataCache()
        postAction()
        return otherDataCache[key]
    }
    
    public static func setData(_ data: Any, for key: String) {
        otherDataCache[key] = data
    }
    
    // TODO : video loading
    
}
