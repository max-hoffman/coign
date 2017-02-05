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
        return error
    }
    
    func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPErrorBlock) {
        
        let path = "charge"
        let params: [String: AnyObject] = [
            "source" : result.source.stripeID as AnyObject,
            "amount" : amount as AnyObject,
            "userID" : UserDefaults.standard.value(forKey: FirTree.UserParameter.UserUID.rawValue) as AnyObject,
            "customerID" : UserDefaults.standard.value(forKey: FirTree.UserParameter.StripeID.rawValue) as AnyObject
        ]
       
        let request = Alamofire.request(baseURLString + path, method: .post, parameters: params, encoding: JSONEncoding.default)
        request.responseJSON() {
            response in
            print(response)
            switch response.result {
            case .success :
                return completion(nil)
            case .failure (let error):
                return completion(error)
            }
        }
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
        var newCustomer = false
        
        if let stripeID = UserDefaults.standard.string(forKey: FirTree.UserParameter.StripeID.rawValue) {
            print(stripeID)
            path = "retrieve-customer"
            params = ["stripeID" : stripeID as AnyObject]
        }
        else if let userID = UserDefaults.standard.string(forKey: FirTree.UserParameter.UserUID.rawValue){
            newCustomer = true
            path = "create-customer"
            params = ["userID" : userID as AnyObject,
                      "new" : true as AnyObject]
        }
        
        let request = Alamofire.request(baseURLString + path, method: .post, parameters: params, encoding: JSONEncoding.default)
        request.responseJSON() {
            response in
            

            switch response.result {
            case .success :
                if let customerData = response.result.value {
                    let deserializer = STPCustomerDeserializer(jsonResponse: customerData)
                    
                    if let error = deserializer.error {
                        completion(nil, error)
                        return
                    } else if let customer = deserializer.customer {
                        if newCustomer {
                            FirTree.newStripeCustomer(stripeID: customer.stripeID)
                        }
                        completion(customer, nil)
                    }
                }

            case .failure (let error):
                return completion(nil, error)
            }
        }
    }
    
    @objc func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
    
        let path = "change-default-source"
        let params = [
            "source": source.stripeID,
            "stripeID" : UserDefaults.standard.value(forKey: FirTree.UserParameter.StripeID.rawValue)
            ]
        
        let request = Alamofire.request(baseURLString + path, method: .post, parameters: params, encoding: JSONEncoding.default)
        request.responseJSON() {
            response in
            
            switch response.result {
            case .success :
                return completion(nil)
            case .failure (let error):
                return completion(error)
            }
        }
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
        let params = [
            "source": source.stripeID,
            "stripeID" : UserDefaults.standard.value(forKey: FirTree.UserParameter.StripeID.rawValue)
            ]
        
        let request = Alamofire.request(baseURLString + path, method: .post, parameters: params, encoding: JSONEncoding.default)
        request.responseJSON() {
            response in
            
            switch response.result {
            case .success :
                return completion(nil)
            case .failure (let error):
                return completion(error)
            }
        }
    }
}
