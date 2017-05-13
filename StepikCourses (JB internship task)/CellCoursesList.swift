//
//  CellCoursesList.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 10.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit

class CellCoursesList: UITableViewCell {
    
    @IBOutlet weak var cover: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var summary: UILabel!
    
    public func clearImage() {
        cover.image = #imageLiteral(resourceName: "StepikLogo")
    }
    
    public func clear() {
        clearImage()
        name.text = nil
        summary.text = nil
    }
    
}
