//
//  CoursesListVC.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 08.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit

class CoursesListVK: UITableViewController {
    
    private var coursesList: [CourseInfo] = []
    private let apiWorker = StepikApiWorker()
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private var busy = false
    private var isRefreshing = false
    
    private func loadCellsBucket(postAction: @escaping () -> () = {}) {
        if (busy) {
            return
        }
        busy = true
        DispatchQueue.global(qos: .userInteractive).async(execute: {() -> Void in
            do {
                let someMoreCourses = try self.apiWorker.getNextCourseList()
                someMoreCourses.forEach({ (course) in
                    self.coursesList.append(course)
                })
            } catch {
                let failViewController = (self.storyboard?.instantiateViewController(
                    withIdentifier: "FailPage"
                ))!
                failViewController.navigationItem.setHidesBackButton(
                    true,
                    animated: true
                )
                self.navigationController?.pushViewController(
                    failViewController,
                    animated: true
                )
            }
            DispatchQueue.main.async {
                postAction()
                self.tableView.reloadData()
            }
            self.busy = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = #colorLiteral(red: 0.9678272605, green: 1, blue: 0.9471178651, alpha: 1)
        refreshControl?.attributedTitle = NSAttributedString(
            string: "refreshing...",
            attributes: [
                NSFontAttributeName: UIFont(
                    name: "Helvetica Neue",
                    size: 18.0
                )!,
                NSForegroundColorAttributeName: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)]
        )
        refreshControl?.tintColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        refreshControl?.addTarget(
            self,
            action: #selector(self.refresh(sender:)),
            for: UIControlEvents.valueChanged
        )
        tableView.addSubview(refreshControl!)
        loadCellsBucket()
    }
    
    func refresh(sender: AnyObject) {
        self.isRefreshing = true
        self.loadingIndicator.stopAnimating()
        self.tableView.tableFooterView?.isHidden = true
        self.apiWorker.refresh()
        DataLoader.resetImageCache()
        self.coursesList = []
        DispatchQueue.global(qos: .userInitiated).async(
            execute: { () -> Void in
                self.loadCellsBucket()
                sleep(1)
                self.isRefreshing = false
                self.refreshControl?.endRefreshing()
            }
        )
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (isRefreshing) {
            return
        }
        let userOfset = scrollView.contentOffset.y
        let maxOfset = scrollView.contentSize.height - scrollView.frame.size.height
        if (userOfset >= maxOfset) {
            tableView.tableFooterView?.isHidden = false
            loadingIndicator.startAnimating()
            loadCellsBucket(postAction: { () -> Void in
                self.tableView.tableFooterView?.isHidden = true
                self.loadingIndicator.stopAnimating()
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCell = tableView.dequeueReusableCell(
            withIdentifier: "CourseInfo",
            for: indexPath
        ) as! CellCoursesList
        if (coursesList.count <= indexPath.row) {
            currentCell.clear()
            loadCellsBucket()
        } else {
            currentCell.name.text = coursesList[indexPath.row].name
            currentCell.summary.text = coursesList[indexPath.row].summary
            DataLoader.loadImage(
                byUrl: coursesList[indexPath.row].cover,
                to: currentCell.cover
            )
        }
        return currentCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coursePage = storyboard?.instantiateViewController(
            withIdentifier: "CoursePage"
        ) as! CourseInfoVC
        coursePage.course = coursesList[indexPath.row]
        navigationController?.pushViewController(
            coursePage,
            animated: true
        )
    }
    
    private func cacheData() {
        DataLoader.saveImgCache()
        DataLoader.saveDataCache()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        cacheData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cacheData()
    }
    
}
