//
//  DBQueryHandler.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class queryHandler{
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    
    init(){}
    
    func scanWithExpression(scanExpression: AWSDynamoDBScanExpression, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        dynamoDBObjectMapper.scan(DBRecipe.self, expression: scanExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error)
                
            })
        })
    }
    func queryRecipeData(completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 100;
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
    }
    func advancedScanNoFilterName(fromTemperature: NSNumber, toTemperature: NSNumber, duration: NSNumber,  completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        let scanExpression = AWSDynamoDBScanExpression()
        
        scanExpression.filterExpression = "#froTemperature > :fromTemperature AND #toTemperature < :toTemperature AND #duration < :duration"
        scanExpression.expressionAttributeNames = [
            "#froTemperature": "temperature",
            "#toTemperature": "temperature",
            "#duration": "duration"
        ]
        scanExpression.expressionAttributeValues = [
            ":fromTemperature": fromTemperature,
            ":toTemperature": toTemperature,
            ":duration": duration
        ]
        
        scanExpression.limit = 10
        
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
    }
    func advancedScan(filterName: String, fromTemperature: NSNumber, toTemperature: NSNumber, duration: NSNumber,  completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        let scanExpression = AWSDynamoDBScanExpression()
        
        scanExpression.filterExpression = "begins_with(#name, :name) AND #froTemperature > :fromTemperature AND #toTemperature < :toTemperature AND #duration < :duration"
        scanExpression.expressionAttributeNames = [
            "#name": "name",
            "#froTemperature": "temperature",
            "#toTemperature": "temperature",
            "#duration": "duration"
        ]
        scanExpression.expressionAttributeValues = [
            ":name": filterName,
            ":fromTemperature": fromTemperature,
            ":toTemperature": toTemperature,
            ":duration": duration
        ]
        
        scanExpression.limit = 10
        
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
        
    }
}
let glblQueryHandler = queryHandler()
