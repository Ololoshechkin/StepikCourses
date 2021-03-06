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

    @IBOutlet weak var videoPlaceholder: UIView!
    @IBOutlet weak var noVideoMessage: UILabel!
    
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var requirementsLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    lazy var labels: () -> [UILabel] = { () -> [UILabel] in
        return [self.summaryLabel, self.descriptionLabel, self.requirementsLabel, self.authorLabel]
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    public var course: CourseInfo?
    private var videoPlayer = AVPlayerViewController()
    @IBOutlet weak var openCourseLinkButton: UIButton!
    
    @IBAction func openCourseLink(_ sender: Any) {
        UIApplication.shared.openURL(
            URL(string: (course?.getLink())!)!
        )
    }
    
    private var player: AVPlayer?
    
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
        DataLoader.loadImage(
            byUrl: (course?.coverPath)!,
            postAction: { (loadedImage) -> Void in
                self.coverImage.image = loadedImage
                if loadedImage == #imageLiteral(resourceName: "StepikLogo") {
                    self.background.backgroundColor = #colorLiteral(red: 0.8950740232, green: 0.8950740232, blue: 0.8950740232, alpha: 1)
                    self.scrollView.backgroundColor = #colorLiteral(red: 0.8950740232, green: 0.8950740232, blue: 0.8950740232, alpha: 1)
                    return
                }
                let color = loadedImage.getAverageColor()
                let alphaColor = color.withAlphaComponent(0.9)
                self.background.backgroundColor = alphaColor
                self.navigationController?.navigationBar.backgroundColor = color
                let rightSideColor = loadedImage.getRightSideColor()
                self.backgroundCover.backgroundColor = rightSideColor
                self.scrollView.backgroundColor = alphaColor
                self.view.backgroundColor = alphaColor
                if (rightSideColor.isDark()) {
                    self.nameLabel.textColor = UIColor.white
                }
                self.openCourseLinkButton.setTitleColor(
                    alphaColor.inverted(),
                    for: .normal
                )
                self.openCourseLinkButton.setTitleColor(
                    alphaColor,
                    for: .selected
                )
                self.videoPlaceholder.backgroundColor = rightSideColor
                self.noVideoMessage.textColor = self.nameLabel.textColor
            }
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (course?.intro == "" || course?.intro == nil) {
            noVideo()
        } else {
            player = AVPlayer(
                url: URL(string: (course?.intro)!)!
            )
        }
    }

    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playVideo(_ sender: Any) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlaceholder.frame
        videoPlaceholder.isHidden = true
        background.layer.addSublayer(playerLayer)
        player?.play()
    }
    
    
    private func noVideo() {
        noVideoMessage.isHidden = false
        UIView.animate(
            withDuration: 0.35,
            animations: {
                self.playButton.isHidden = true
                let deltaX = CGFloat(0.0)
                let deltaY = CGFloat(60.0) - self.videoPlaceholder.frame.height
                let move : (inout CGRect) -> Void = { (frame) -> Void in
                    frame = frame.offsetBy(dx: deltaX, dy: deltaY)
                }
                self.labels().forEach({ (label) in
                    move(&label.frame)
                })
                move(&self.openCourseLinkButton.frame)
                self.videoPlaceholder.frame = CGRect(
                    x: self.videoPlaceholder.frame.minX,
                    y: self.videoPlaceholder.frame.minY,
                    width: self.videoPlaceholder.frame.width,
                    height: CGFloat(60.0)
                )
            }
        )
    }
    
}
