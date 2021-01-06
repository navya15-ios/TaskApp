//
//  CreateProductExtension.swift
//  TaskApp
//
//  Created by Navya Srujana on 05/01/21.
//

import Foundation
import UIKit

extension CreateProductViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK:- UIImage Picker Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            
            self.performMultipartImageUpload(image: pickedImage, successHandler: { (response) in
                print("success Response: ",response)
                self.productIMGOutlet.image = pickedImage
                self.productImageHeight.constant = 150
                UIView.animate(withDuration: 1.0) {
                    self.view.layoutIfNeeded()
                }
                
            }, failureHandler: { (error) in
                //print("error for failure",error)
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Upload Image API
    func performMultipartImageUpload(image: UIImage, successHandler: ((NSDictionary)->())?, failureHandler: ((String) -> ())?) {
        let reqUrl: String = WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.UploadImage.rawValue
        let pUrl = URL(string: reqUrl)
        let request = NSMutableURLRequest(url: pUrl!)
        request.httpMethod = "POST"
        let boundary = genarateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = image.jpegData(compressionQuality: 0.5)
        if imageData == nil
        {
            return
        }
        request.httpBody = createBodyWithParameters(filePathKey: "image", imageDataKey: imageData!, boundary: boundary)
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest){
            data,response,error in
            if let data = data {
                do {
                    if (error != nil) {
                        if let errorDetails = response as? [String: Any] {
                            failureHandler?((errorDetails["ErrorMessage"] as? String)!)
                        } else {
                            failureHandler?("Some thing went wrong,Please try again later!")
                        }
                    }
                    let str = String(data: data, encoding: .utf8)
                    if let anEncoding = str?.data(using: .utf8) {
                        let jsonObject = try? JSONSerialization.jsonObject(with: anEncoding, options:[])
                        var jsonDict:NSDictionary = NSDictionary()
                        jsonDict = (jsonObject as? NSDictionary)!
                        //print(jsonDict)
                        DispatchQueue.main.async {
                            successHandler?(jsonDict)
                        }
                    }
                }
                catch let error as NSError {
                    if let errorDetails = response as? Dictionary<String, Any> {
                        failureHandler?((errorDetails["ErrorMessage"] as? String)!)
                    } else {
                        failureHandler?("Some thing went wrong,Please try again later!")
                    }
                }
            } else {
                failureHandler?("Some thing went wrong,Please try again later!")
            }
        }
        dataTask.resume()
    }
    //MARK:- Upload Image Boundary
    func genarateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    //MARK:- Upload Image Parameters
    func createBodyWithParameters(filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data()
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageDataKey)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body as Data
    }
}
//MARK:- Helper Methods
extension CreateProductViewController {
    func reloadDataFromEdit() {
        let urlString = WebServiceEndPoints.Base.rawValue+WebServiceEndPoints.DeleteProduct.rawValue+id+WebServiceEndPoints.EditProductAppended.rawValue
        print("urlString : ",urlString)
        WebService.sharedService.request(method: "GET", path: urlString, parameters: nil) { (respose) in
            print("Edit API Response : ",respose)
            if let dict = respose as? [String: Any] {
                self.dataForEdit = dict
                self.updateUIForEdit()
            }
            
        } failureHandler: { (error) in
            print("Error : ",error)
            let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateUIForEdit() {
        let title = dataForEdit["title"] as? String ?? ""
        appartmentId = dataForEdit["appartmentId"] as? String ?? ""
        let description = dataForEdit["description"] as? String ?? ""
        self.titleTFOutlet.text = title
        if let appartmentName = getAppartmentNameWithID() {
            self.appartmentBTNOutlet.setTitle(appartmentName, for: .normal)
        }
        self.discriptionTextView.text = description
        self.discriptionTextView.textColor = UIColor.black
        self.createBTNOutlet.tag = 2
        self.createBTNOutlet.setTitle("Update", for: .normal)
    }
    func getDropDownArrayObject() -> [String] {
        var dropDownValues = [String]()
        for object in dropDownArray {
            print("object :",object)
            if let name  = object["appartmentName"] as? String {
                dropDownValues.append(name)
            }
        }
        return dropDownValues
    }
    
    func getAppartmentNameWithID() -> String? {
        if let appartmentDict = dataForEdit["appartment"] as? [String: Any] {
            return appartmentDict["appartmentName"] as? String
        }
        return nil
    }
    func getIDForSelectedAppartment() -> String? {
        let name = appartmentBTNOutlet.titleLabel!.text ?? ""
        let filterDict = dropDownArray.filter({$0["appartmentName"] as? String ?? "" == name})
        if filterDict.count>0 {
            let dict = filterDict[0]
            return dict["id"] as? String
        }
        return nil
    }
    func updateEditedData() {
        dataForEdit["title"] = titleTFOutlet.text
        if let appartmentId = getIDForSelectedAppartment() {
            print("appartmentId :",appartmentId)
            dataForEdit["appartmentId"] = appartmentId
        }
        dataForEdit["description"] = discriptionTextView.text
    }
    
    func validationForCreateProduct() -> (Bool, [String: Any]) {
        guard let title = titleTFOutlet.text, !title.isEmpty  else {
            print("Please enter title")
            let alert = UIAlertController(title: "", message: "Please Enter Title", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return (false, [:])
        }
        guard let description = discriptionTextView.text, !description.isEmpty else {
            print("Please enter description")
            let alert = UIAlertController(title: "", message: "Please Enter description", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return (false, [:])
        }
        if description == "Please Enter description" {
            print("please enter description")
            let alert = UIAlertController(title: "", message: "Please Enter description", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return (false, [:])
        }
        if let appartmentId = getIDForSelectedAppartment() {
            print("appartmentId :",appartmentId)
            var parameter = [String: Any]()
            
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            // Set Date Format
            dateFormatter.dateFormat = "YY/MM/dd"
            // Convert Date to String
            let date = dateFormatter.string(from: Date())
            
            parameter["status"] = 1000
            parameter["title"] = title
            parameter["description"] = description
            parameter["appartmentId"] = appartmentId
            parameter["images"] = "user-profile.jpg"
            parameter["postdate"] = date
            return (true, parameter)
        } else {
            print("Please select the appartment")
            let alert = UIAlertController(title: "", message: "Please select the appartment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return (false, [:])
        }
    }
}
