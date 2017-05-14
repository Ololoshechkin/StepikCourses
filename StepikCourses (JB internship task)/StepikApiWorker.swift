//
//  StepikApiWorker.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 07.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit

class StepikApiWorker {
    
    private static let stepikAddress = "https://stepik.org:443/api/"
    private var lastBucketNumber = 0
    
    private class func abstractCourseQuery(querryType: String, page: Int, excludeEnded: Bool = true, isPublic: Bool = true) -> String {
        return querryType
            + "?exclude_ended=\(excludeEnded)"
            + "&is_public=\(isPublic)"
            + "&order=-activity"
            + "&page=\(page)"
    }
    
    
    private class func coursesQuery(page: Int, full: Bool = true) -> String {
        return StepikApiWorker.abstractCourseQuery(
            querryType: "courses",
            page: page
        )
    }
    
    private class func coursesTotalStatsQuery(page: Int) -> String {
        return StepikApiWorker.abstractCourseQuery(
            querryType: "course-total-statistics",
            page: page
        )
    }
    
    private class func usersQuery(ids: [Int]) -> String {
        return "users?" + ids.map({(id) -> String in
            return "ids%5B%5D=\(id)"
        }).joined(separator: "&")
    }

    private class func query(apiFunction: String) throws -> Data {
        if let data = DataLoader.getCachedData(by: apiFunction) {
            return data as! Data
        }
        let dataFromWeb =  try Data(
            contentsOf: URL(string: StepikApiWorker.stepikAddress + apiFunction)!
        )
        DataLoader.setData(dataFromWeb, for: apiFunction)
        return dataFromWeb
    }
    
    private class func coursesQuery(part: String, _ bucket: Int, full: Bool = true)
        throws -> Any? {
        return (try JSONSerialization.jsonObject(
            with: StepikApiWorker.query(
                apiFunction: full ? StepikApiWorker.coursesQuery(
                    page: bucket
                ) : StepikApiWorker.coursesTotalStatsQuery(
                    page: bucket
                )
            )
        ) as! [String: Any])[part]
    }
    
    public class func usersInfoQuery(ids: [Int]) throws -> [UserInfo] {
        let responce = try JSONSerialization.jsonObject(
            with: StepikApiWorker.query(apiFunction: usersQuery(ids: ids))
        )
        let usersDict = (responce as! [String: Any])["users"] as! [[String: Any]]
        return ids.enumerated().map({ (i, id) -> UserInfo in
            print("\(i) \(id)")
            return UserInfo(
                firstName: usersDict[i]["first_name"] as! String,
                secondName: usersDict[i]["last_name"] as! String,
                alias: usersDict[i]["alias"] as? String,
                avatarSufix: usersDict[i]["avatar"] as? String ?? ""
            )
        })
    }
    
    private class func getCourseList(bucket: Int) throws -> [CourseInfo] {
        let courses = try StepikApiWorker.coursesQuery(
            part: "courses",
            bucket
        ) as! [[String: Any]]
        return courses.map({(course) -> CourseInfo in
            return CourseInfo(
                id: course["id"] as! Int,
                name: course["title"] as? String ?? "a course has no name",
                summary: course["summary"] as? String ?? "open to see more",
                coverSufix: course["cover"] as? String ?? "",
                description: course["description"] as? String ?? "no description",
                intro: course["intro"] as? String ?? "no introduction",
                requirements: course["requirements"] as? String ?? "everyone can try!",
                authorIds: course["instructors"] as! [Int]
            )
        })
    }
    
    private class func existBucket(after bucketNumber: Int) throws -> Bool {
        if (bucketNumber == 0) {
            return true
        }
        let meta = try StepikApiWorker.coursesQuery(
            part: "meta",
            bucketNumber,
            full: true
        ) as! [String: Any]
        return meta["has_next"] as! Bool
    }
    
    
    public func getNextCourseList() throws -> [CourseInfo] {
        if (try StepikApiWorker.existBucket(after: lastBucketNumber)) {
            lastBucketNumber += 1
            return try StepikApiWorker.getCourseList(bucket: lastBucketNumber)
        } else {
            return []
        }
    }
    
    public func refresh() {
        DataLoader.resetOtherDataCache()
        lastBucketNumber = 0
    }
    
}
