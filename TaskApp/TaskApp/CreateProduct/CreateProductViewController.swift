//
//  CreateProductViewController.swift
//  TaskApp
//
//  Created by Navya Srujana on 05/01/21.
//

import UIKit
import DropDown

class CreateProductViewController: UIViewController {
    // DropDown
    let dropDown = DropDown()
    // Create or Edit Card
    @IBOutlet weak var productImageHeight: NSLayoutConstraint!{
        didSet{
            productImageHeight.constant = 0
        }
    }
    @IBOutlet weak var appartmentBTNOutlet: UIButton! {
        didSet{
            appartmentBTNOutlet.setTitle("Select Appartment", for: .normal)
        }
    }
    @IBOutlet weak var titleTFOutlet: UITextField!
    @IBOutlet weak var productIMGOutlet: UIImageView!
    @IBOutlet weak var createBTNOutlet: UIButton!
    var imagePicker = UIImagePickerController()
    var dropDownArray = Array<[String: Any]>()
    @IBOutlet weak var discriptionTextView: UITextView! {
        didSet{
            discriptionTextView.layer.cornerRadius = 10
            discriptionTextView.layer.borderWidth = 1
            discriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
            discriptionTextView.clipsToBounds = true
            discriptionTextView.text = "Please Enter description"
            discriptionTextView.textColor = UIColor.lightGray
            discriptionTextView.delegate = self
        }
    }
    // outlets For Edit
    var dataForEdit = [String: Any]()
    var id = ""
    var appartmentId = ""
    var isFromEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        createBTNOutlet.tag = 0
        WebService.sharedService.request(method: "GET", path: WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.GetAppartments.rawValue, parameters: nil) { (response) in
            print("success in get appartment list :", response)
            if let jsonArray = response as? Array<[String: Any]> {
                self.dropDownArray = jsonArray
                if self.isFromEdit {
                    self.reloadDataFromEdit()
                }
            }
        } failureHandler: { (error) in
            print("error :", error)
            let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func backBTNAction(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func editImageBTNAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } 
    }
    
    @IBAction func appartmentListDropdown(_ sender: UIButton) {
        dropDown.dataSource = self.getDropDownArrayObject()
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height+16)
        dropDown.cornerRadius = 5
        dropDown.clipsToBounds = true
        dropDown.show() //7
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
            guard let _ = self else { return }
            sender.setTitle(item, for: .normal) //9
        }
    }
    
    @IBAction func createBTNAction(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.setTitle("Create", for: .normal)
            sender.tag = 1
            
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                imagePicker.sourceType = .savedPhotosAlbum
                imagePicker.allowsEditing = false
                present(imagePicker, animated: true, completion: nil)
            }             
        } else if sender.tag == 1 {
            let validation = self.validationForCreateProduct()
            if validation.0 == true {
                let parameter = validation.1
                WebService.sharedService.request(method: "POST", path: WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.CreateProduct.rawValue, parameters: parameter) { (response) in
                    print("create appartment response: ", response)
                    self.dismiss(animated: false, completion: nil)
                } failureHandler: { (error) in
                    print("error : ", error)
                    let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if sender.tag == 2 {
            self.updateEditedData()
            WebService.sharedService.request(method: "PUT", path: WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.UpdateProduct.rawValue, parameters: dataForEdit) { (response) in
                print("response for update : ",response)
                self.dismiss(animated: false, completion: nil)
            } failureHandler: { (error) in
                print("error : ",error)
                let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
//MARK:- UITextViewDelegate Methods
extension CreateProductViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please Enter description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    public func textViewDidChange(_ textView: UITextView){
        let fixedWidth = discriptionTextView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        discriptionTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
    }
}
