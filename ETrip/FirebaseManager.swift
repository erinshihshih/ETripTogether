//
//  FirebaseManager.swift
//  ETrip
//
//  Created by Erin Shih on 2016/10/13.
//  Copyright © 2016年 Erin Shih. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol FirebaseManagerDelegate: class {
    
    func getPostManager(getPostManager: FirebaseManager, didGetData post: Post)
    
    func getTransportationManager(getTransportationManager: FirebaseManager, didGetData transportation: Transportation)
    
    func getAttractionManager(getAttractionManager: FirebaseManager, didGetData attraction: Attraction)
    
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    weak var delegate: FirebaseManagerDelegate?
    
    let databaseRef = FIRDatabase.database().reference()
    
    var posts: [Post] = []
    var transportations: [Transportation] = []
    var attractions: [Attraction] = []
    
    func fetchPosts() {
        
        databaseRef.child("posts").queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if snapshot.exists() {
                
                self.posts = []
                
                for item in [snapshot.value] {
                    
                    guard let itemDictionary = item as? NSDictionary else {
                        fatalError()
                    }
                    
                    guard let firebaseItemKey = itemDictionary.allKeys as? [String] else {
                        fatalError()
                    }
                    
                    guard let firebaseItemValue = itemDictionary.allValues as? [NSDictionary] else {
                        fatalError()
                    }
                    
                    for (index, item) in firebaseItemValue.enumerate() {
                        
                        let postID = firebaseItemKey[index]
                        
                        let indexPathRow = item["indexPathRow"] as! Int
                        let title = item["title"] as! String
                        let country = item["country"] as! String
                        let startDate = item["startDate"] as! String
                        let returnDate = item["returnDate"] as! String
                        
                        let post = Post(postID: postID, indexPathRow: indexPathRow, title: title, country: country, startDate: startDate, returnDate: returnDate)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.getPostManager(self, didGetData: post)
                        }
                        
                    }
                }
                
            }
            //
            
            //        databaseRef.child("posts").queryOrderedByChild("timestamp").observeEventType(.ChildAdded, withBlock: {
            
            
            //            print(snapshot.value)
            //
            //            let posts = snapshot.value! as! [String : AnyObject]
            //            let postID = snapshot.key
            //            print(postID)
            //            let indexPathRow = posts["indexPathRow"] as! Int
            //            let title = posts["title"] as! String
            //            let country = posts["country"] as! String
            //            let startDate = posts["startDate"] as! String
            //            let returnDate = posts["returnDate"] as! String
            //
            //            let post = Post(postID: postID, indexPathRow: indexPathRow, title: title, country: country, startDate: startDate, returnDate: returnDate)
            //            dispatch_async(dispatch_get_main_queue()) {
            //                self.delegate?.getPostManager(self, didGetData: post)
            //            }
            
        })
    }
    
    func fetchTransportations() {
        
        databaseRef.child("transportations").queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            guard let transportationDict = snapshot.value as? NSDictionary else {
                fatalError()
            }
            
            let postID = transportationDict["postID"] as! String
            let indexPathRow = transportationDict["indexPathRow"] as! Int
            let type = transportationDict["type"] as! String
            let airlineCom = transportationDict["airlineCom"] as! String
            let flightNo = transportationDict["flightNo"] as! String
            let bookingRef = transportationDict["bookingRef"] as! String
            let departFrom = transportationDict["departFrom"] as! String
            let arriveAt = transportationDict["arriveAt"] as! String
            let departDate = transportationDict["departDate"] as! String
            let arriveDate = transportationDict["arriveDate"] as! String
            
            let transportation = Transportation(postID: postID, indexPathRow: indexPathRow, type: type, departDate: departDate, arriveDate: arriveDate, departFrom: departFrom, arriveAt: arriveAt, airlineCom: airlineCom, flightNo: flightNo, bookingRef: bookingRef)
            
            self.delegate?.getTransportationManager(self, didGetData: transportation)
            
        })
        
    }
    
    func fetchAttractions() {
        
        databaseRef.child("attractions").queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            guard let attractionDict = snapshot.value as? NSDictionary else {
                fatalError()
            }
            
            let postID = attractionDict["postID"] as! String
            let indexPathRow = attractionDict["indexPathRow"] as! Int
            let name = attractionDict["name"] as! String
            let stayHour = attractionDict["stayHour"] as! String
            let address = attractionDict["address"] as! String
            let note = attractionDict["note"] as! String
            
            
            let attraction = Attraction(postID: postID, indexPathRow: indexPathRow, name: name, stayHour: stayHour, address: address, note: note)
            
            self.delegate?.getAttractionManager(self, didGetData: attraction)
            
        })
        
    }
    
    
    
    
    
    
}