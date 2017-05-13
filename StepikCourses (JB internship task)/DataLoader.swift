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
        UserDefaults.standard.setValue(
            imageCache,
            forKey: "imageCache"
        )
        UserDefaults.standard.synchronize()
        imgCacheIsLoaded = true
    }
    
    public static func saveDataCache() {
        UserDefaults.standard.setValue(
            otherDataCache,
            forKey: "otherDataCache"
        )
        UserDefaults.standard.synchronize()
        dataCacheIsLoaded = true
    }
    
    public static func loadImgCache() {
        if (!imgCacheIsLoaded) {
            imageCache = UserDefaults.standard.value(
                forKey: "imageCache"
            ) as? [String: UIImage] ?? [:]
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
    
    public static func loadImage(byUrl url: String, to imageView: UIImageView, postAction: @escaping () -> () = {}) {
        loadImgCache()
        if let cachedImage = imageCache[url] {
            DispatchQueue.main.async {
                imageView.image = cachedImage
                postAction()
            }
        }
        let task = URLSession.shared.dataTask(
            with: URL(string: url)!
        ) { (responseData, responseUrl, error) -> () in
            DispatchQueue.main.async(execute: { () -> Void in
                if let data = responseData {
                    imageView.image = UIImage(data: data)
                } else {
                    imageView.image = #imageLiteral(resourceName: "StepikLogo")
                }
                postAction()
            })
            
        }
        task.resume()
    }
    
    public static func getCachedData(by key: String, postAction: @escaping () -> () = {}) -> Any? {
        loadDataCache()
        postAction()
        return otherDataCache[key]
    }
    
    public static func setData(_ data: Any, for key: String) {
        otherDataCache[key] = data
    }
    
    // TODO : video loading, huge files loading etc.
    
}
