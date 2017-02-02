//
//  APIClient.swift
//  Coign
//
//  Template created by Ben Guo on 4/25/16.
//  Copyright © 2016 Stripe. All rights reserved.
//
//  Created by Maximilian Hoffman on 1/27/17.
//  Copyright © 2017 Exlent Studios. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class APIClient: NSObject, STPBackendAPIAdapter {
    
    static let sharedClient = APIClient()
    let session: URLSession
    let baseURLString = "https://www.coign.co/api/"
    var defaultSource: STPCard? = nil
    var sources: [STPCard] = []
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession(configuration: configuration)
        super.init()
    }
    
    func decodeResponse(_ response: URLResponse?, error: NSError?) -> NSError? {
        if let httpResponse = response as? HTTPURLResponse
            , httpResponse.statusCode != 200 {
            return error ?? NSError.networkingError(httpResponse.statusCode)
        }
        print(error)
        return error
    }
    
    func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPErrorBlock) {
        guard let baseURL = URL(string: baseURLString) else {
            let error = NSError(domain: StripeDomain, code: 50, userInfo: [
                NSLocalizedDescriptionKey: "Please set baseURLString to your API URL in CheckoutViewController.swift"
                ])
            completion(error)
            return
        }
        let path = "charge"
        let url = baseURL.appendingPathComponent(path)
        let params: [String: AnyObject] = [
            "source": result.source.stripeID as AnyObject,
            "amount": amount as AnyObject
        ]
       
        let request = URLRequest.request(url, method: .POST, params: params)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
    
    @objc func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        guard let key = Stripe.defaultPublishableKey() , !key.contains("#") else {
            let error = NSError(domain: StripeDomain, code: 50, userInfo: [
                NSLocalizedDescriptionKey: "Please set stripePublishableKey to your account's test publishable key in CheckoutViewController.swift"
                ])
            completion(nil, error)
            return
        }
        guard let baseURL = URL(string: baseURLString) else {
            let error = NSError(domain: StripeDomain, code: 50, userInfo: [
                NSLocalizedDescriptionKey: "Please set baseURLString to your API URL in CheckoutViewController.swift"
                ])
            completion(nil, error)
            return
        }
        
        var path: String = ""
        var params: [String : AnyObject] = [:]
        
        if let stripeID = UserDefaults.standard.string(forKey: FirTree.UserParameter.StripeID.rawValue) {
            path = "retrieve-customer"
            params = ["stripeID" : stripeID as AnyObject]
        }
        else if let userID = UserDefaults.standard.string(forKey: FirTree.UserParameter.UserUID.rawValue){
            path = "create-customer"
            params = ["userID" : userID as AnyObject,
                      "new" : true as AnyObject]
        }
        
        //let url = baseURL.appendingPathComponent(path)
        //let request = URLRequest.request(url, method: .POST, params: params)
        
        let request = Alamofire.request(baseURLString + path, method: .post, parameters: params, encoding: JSONEncoding.default)
        request.responseJSON() {
            response in
            
            let parser = JSONParser()
            let data = parser.parseJSON(response.result.value)
            let deserializer = STPCustomerDeserializer(jsonResponse: response.result.value)
            
//            print("response: \(response)")
//            print("result: \(response.result)")
//            print("value: \(response.result.value as! NSDictionary)")

            if let error = deserializer.error {
                completion(nil, error)
                print(error)
                return
            } else if let customer = deserializer.customer {
                completion(customer, nil)
            }
        }

//        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
//            DispatchQueue.main.async {
//                
//                //this data isn't being parsed correctly
//                print(NSData(data: data!))
//                //let parser = JSONParser()
//                //print(parser.parseJSON(data))
//                
//                let deserializer = STPCustomerDeserializer(data: data, urlResponse: urlResponse, error: error)
//                if let error = deserializer.error {
//                    completion(nil, error)
//                    print(error)
//                    return
//                } else if let customer = deserializer.customer {
//                    print(error)
//                    completion(customer, nil)
//                }
//            }
//        }
//        task.resume()
    }
    
    @objc func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        guard let baseURL = URL(string: baseURLString) else {
            if let token = source as? STPToken {
                self.defaultSource = token.card
            }
            completion(nil)
            return
        }
        let path = "change-default-source"
        let url = baseURL.appendingPathComponent(path)
        let params = [
            "source": source.stripeID,
            ]
        let request = URLRequest.request(url, method: .POST, params: params as [String : AnyObject])
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
    
    @objc func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        guard let baseURL = URL(string: baseURLString) else {
            if let token = source as? STPToken, let card = token.card {
                self.sources.append(card)
                self.defaultSource = card
            }
            completion(nil)
            return
        }
        let path = "add-source"
        let url = baseURL.appendingPathComponent(path)
        let params = [
            "source": source.stripeID
            ]
        let request = URLRequest.request(url, method: .POST, params: params as [String : AnyObject])
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
    
}
