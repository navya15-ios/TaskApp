//
//  ProductViewController.swift
//  TaskApp
//
//  Created by Navya Srujana on 05/01/21.
//

import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var productTVOutlet: UITableView!
    var cardArray = Array<[String: Any]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.productTVOutlet.delegate = self
        self.productTVOutlet.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refreshTheCardList()
    }
    
    func refreshTheCardList() {
        WebService.sharedService.request(method: "GET", path: WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.GetAllProducts.rawValue, parameters: nil) { (response) in
            print("response for get all product : ", response)
            if let array = response as? Array<[String: Any]> {
                let filteredArray = array.filter({$0["title"] as? String != nil && $0["title"] as? String != ""})
                self.cardArray = filteredArray
            }
            self.productTVOutlet.reloadData()
        } failureHandler: { (error) in
            print("error: ", error)
            let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 
    @IBAction func createCardBTNAction(_ sender: UIButton) {
        let createCardVC = self.storyboard?.instantiateViewController(identifier: "CreateProductViewController") as! CreateProductViewController
        
        self.present(createCardVC, animated: false, completion: nil)
    }
    
}

