
//
//  Webservice.swift
//  Rehlat
//
//  Created by Navya Srujana on 14/11/17.
//  Copyright © 2017 Vincent Joy. All rights reserved.
//

import UIKit

typealias CompletionBlock = (_ success:Int, _ result:Any?) -> ()

enum Completion {
    case success(Any)
    case failure(Error)
}

enum WebServiceEndPoints: String {
    
    /* Authentication */
    case Base               =   "http://18.136.149.198:2020/api/"
    case UploadImage        =   "containers/users/upload"
    case UpdateProduct      =   "noticeboards/editNoticeboardData"
    case CreateProduct      =   "noticeboards/createPost"
    case GetAppartments     =   "appartments"
    case DeleteProduct      =   "noticeboards/"
    case GetAllProducts     =   "noticeboards?filter[include]=userData&filter[order]=postdate%20DESC"
    case EditProductAppended =   "?filter[include]=appartment&filter[include]=noticeboardImageData"
}

class WebService {
    
    static let sharedService = WebService()
    
    func request(method: String, path: String, parameters: Any? = nil, successHandler: ((Any)->())?, failureHandler: ((String) -> ())?) {
        if let url = URL(string: path) {
            var request = URLRequest(url: url)
            request.httpMethod = method
            
            if let param = parameters as? Dictionary<String,Any> {
                request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: [])
            } else if let param = parameters as? String {
                request.httpBody = param.data(using: .utf8, allowLossyConversion: false)!
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest){
                data,response,error in
                
                if let data = data {
                    do
                    {
                        
                        if (error != nil)
                        {
                            if let errorDetails = response as? [String: Any]  {
                                failureHandler?((errorDetails["ErrorMessage"] as? String)!)
                            }else {
                                failureHandler?("Some thing went wrong,Please try again later!")
                            }
                        }
                        let str = String(data: data, encoding: .utf8)
                        if let anEncoding = str?.data(using: .utf8) {
                            let jsonObject = try? JSONSerialization.jsonObject(with: anEncoding, options:[])
                            DispatchQueue.main.async {
                                successHandler?(jsonObject)
                            }
                        }
                    }
                    catch let error as NSError
                    {
                        if let errorDetails = response as? Dictionary<String, Any> {
                            failureHandler?((errorDetails["ErrorMessage"] as? String)!)
                        }else {
                            failureHandler?("Some thing went wrong,Please try again later!")
                        }
                    }
                }else {
                    failureHandler?("Some thing went wrong,Please try again later!")
                }
            }
            dataTask.resume()
        }
    }
}

