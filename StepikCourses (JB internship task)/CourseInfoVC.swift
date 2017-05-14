//
//  CourseInfoVC.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 12.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVKit

class CourseInfoVC: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var backgroundCover: UIView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var requirementsLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    public var course: CourseInfo?
    private var videoPlayer = AVPlayerViewController()
    
    @IBAction func openCourseLinkButton(_ sender: Any) {
        UIApplication.shared.openURL(
            URL(string: (course?.getLink())!)!
        )
    }
    
    private func getProceedText(title: String, content: String) -> NSAttributedString? {
        return try! NSAttributedString(
            data: ("<p>\(title):</p>" + content + "\n").data(
                using: String.Encoding.unicode,
                allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = course?.name
        summaryLabel.attributedText = getProceedText(
            title: "Summary",
            content: (course?.summary)!
        )!
        descriptionLabel.attributedText = getProceedText(
            title: "About course",
            content: (course?.description)!
        )!
        requirementsLabel.attributedText = getProceedText(
            title: "Requirements",
            content: (course?.requirements)!
        )!
        authorLabel.attributedText = getProceedText(
            title: "Authors",
            content: (course?.authors.map({ (author) -> String in
                return "<p>" + author.name + "</p>"
            }).joined(separator: ""))!
        )!
        let contentFont = UIFont(name: summaryLabel.font.fontName, size: 18)
        [summaryLabel, descriptionLabel, requirementsLabel, authorLabel].forEach { (label) in
            label?.font = contentFont
            label?.sizeToFit()
        }
        print("gonna load image")
        DataLoader.loadImage(
            byUrl: (course?.coverPath)!,
            postAction: { (loadedImage) -> Void in
                print("post action")
                self.coverImage.image = loadedImage
                print("cover image is set!")
                let color = loadedImage.getAverageColor()
                print("getAverageColor")
                let alphaColor = color.withAlphaComponent(0.9)
                self.background.backgroundColor = alphaColor
                self.navigationController?.navigationBar.backgroundColor = color
                let rightSideColor = loadedImage.getRightSideColor()
                self.backgroundCover.backgroundColor = rightSideColor
                self.scrollView.backgroundColor = alphaColor
                self.view.backgroundColor = alphaColor
                print("before (is dark)")
                if (rightSideColor.isDark()) {
                    self.nameLabel.textColor = UIColor.white
                }
                print("after (is dark)")
            }
        )
    }
    
}
