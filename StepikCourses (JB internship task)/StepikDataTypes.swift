//
//  StepikDataTypes.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 14.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit

struct CourseInfo {
    let id: Int
    let name: String
    let summary: String
    let coverSufix: String
    var coverPath: String {
        return "https://stepik.org\(coverSufix)"
    }
    let description: String
    let intro: String
    let requirements: String
    let authorIds: [Int]
    var authors: [UserInfo] {
        do {
            return try StepikApiWorker.usersInfoQuery(ids: authorIds)
        } catch {
            return []
        }
    }
    func getLink() -> String {
        return "https://stepik.org/course/\(id)/"
    }
}

struct UserInfo {
    let firstName: String
    let secondName: String
    let alias: String?
    var name: String {
        return "\(firstName) \(secondName)"
    }
    let avatarSufix: String
    var avatar: String {
        return "https://stepik.org\(avatarSufix)"
    }
}
