//
//  CategoryViewController.swift
//  simpleCounter
//
//  Created by masapp on 2018/04/05.
//  Copyright © 2018 masapp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var tableView: UITableView!
    
    private let defaults = UserDefaults.standard
    private var categories: [String] = []
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = AdSettings.unitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onTapAddButton))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.title = "Category"
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        if let categories = defaults.object(forKey: "category") as? [String] {
            self.categories = categories
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        contentVC.setup(category: categories[indexPath.row])
        navigationController?.pushViewController(contentVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
        cell.bind(categories[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let data = defaults.object(forKey: categories[indexPath.row]) as? Data {
                if let items = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Item] {
                    for item in items {
                        defaults.removeObject(forKey: item.title)
                    }
                }
            }
            defaults.removeObject(forKey: categories[indexPath.row])
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    // MARK: - @objc function
    @objc private func onTapAddButton() {
        let alert = UIAlertController(title: "New Category", message: "Enter a name for this category", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Save", style: .default, handler: { action -> Void in
            if let textFields = alert.textFields as Array<UITextField>? {
                for textField in textFields {
                    self.addCategory(name: textField.text!)
                }
            }
        })
        addAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        alert.addTextField(configurationHandler: { textField -> Void in
            textField.placeholder = "Name"

            NotificationCenter.default.addObserver(
                forName: .UITextFieldTextDidChange,
                object: textField,
                queue: OperationQueue.main,
                using: { _ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let isEmpty = textCount == 0
                    addAction.isEnabled = !isEmpty
            })
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - private
    private func saveData() {
        defaults.set(categories, forKey: "category")
        defaults.synchronize()
    }
    
    private func addCategory(name: String) {
        categories.append(name)
        saveData()
        tableView.reloadData()
    }
}
