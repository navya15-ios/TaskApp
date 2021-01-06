//
//  ViewModelExtension.swift
//  TaskApp
//
//  Created by Navya Srujana on 05/01/21.
//

import Foundation
import UIKit

extension ProductViewController: UITableViewDelegate,UITableViewDataSource {
    // MARK: - Table View DataSource
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardArray.count
    }

    // MARK: - Table View Delegates

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        cell.accessoryType = UITableViewCell.AccessoryType.none
        cell.selectionStyle = .none
        
        if let object = self.cardArray[indexPath.row] as? [String: Any] {
            cell.titleLBLOutlet.text = object["title"] as? String ?? ""
            cell.descriptionLBLOutlet.text = object["description"] as? String ?? ""
        }
       
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextDeleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //Code I want to do here
            if let IDForDelete = self.cardArray[indexPath.row] as? [String: Any] {
                let ID = IDForDelete["id"] as? String ?? ""
                WebService.sharedService.request(method: "DELETE", path: WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.DeleteProduct.rawValue+ID, parameters: nil) { (response) in
                    print("Delete Card :",response)
                    self.refreshTheCardList()
                } failureHandler: { (error) in
                    print("error : ",error)
                    let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        let contextEditItem = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
            //Code I want to do here
            if let dataForEdit = self.cardArray[indexPath.row] as? [String: Any] {
                if let idForEdit = dataForEdit["id"] as? String {
                    let createCardVC = self.storyboard?.instantiateViewController(identifier: "CreateProductViewController") as! CreateProductViewController
                    createCardVC.isFromEdit = true
                    createCardVC.id = idForEdit
                    self.present(createCardVC, animated: false, completion: nil)
                } else {
                    print("ID for edit not available")
                    let alert = UIAlertController(title: "", message: "Something went wrong", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        contextEditItem.backgroundColor = UIColor(red: 0.2436070212, green: 0.5393256153, blue: 0.1766586084, alpha: 1)
        let swipeActions = UISwipeActionsConfiguration(actions: [contextDeleteItem, contextEditItem])

        return swipeActions
    }
}
