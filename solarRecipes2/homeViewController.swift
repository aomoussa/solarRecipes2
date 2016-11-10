//
//  homeViewController.swift
//  solaRecipes
//
//  Created by Ahmed Moussa on 11/09/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class homeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    var recipeCreatorPPDownloadedAtIndex = [Bool]()
    var recies = [recipe]()
    
    private var manager: AWSUserFileManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeCollectionView.delegate = self
        recipeCollectionView.dataSource = self
        //recipeCollectionView. = self
        
        getRecipeData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- starts
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return recies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! recipeCollectionViewCell
        cell.recipeNameLabel.text = recies[indexPath.row].recie?._name
        cell.tempValueLabel.text = String(describing: (recies[indexPath.row].recie?._temperature)!)
        cell.durValueLabel.text = String(describing: (recies[indexPath.row].recie?._duration)!)
        if( recies[indexPath.row].picures.count > 1){
            cell.recipeImageView.image = recies[indexPath.row].picures[1]
        }
        /*were supposed to be lines.. ignore for now
        let cellHeight = self.view.frame.height/2
        let cellWidth = self.view.frame.width/2.2
        
        let lineAtBottom = UIView(frame: CGRect(x: cellWidth*0.15, y: cellHeight, width: cellWidth*0.7, height: 5.0))
        let lineAtSide = UIView(frame: CGRect(x: cellWidth, y: cellHeight*0.15, width: 5.0, height: cellHeight*0.7))
        
        lineAtBottom.backgroundColor = UIColor.gray
        lineAtSide.backgroundColor = UIColor.gray
        
        cell.addSubview(lineAtBottom)
        cell.addSubview(lineAtSide)
        */
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        return CGSize(width: screenWidth/2.05, height: screenHeight/2.5)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        populatePicturesAtIndex(i: indexPath.row)
    }
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
    func populatePicturesAtIndex(i: Int){
        
        if(recies[i].picures.count == 0){
            recies[i].picures.append(UIImage(named: "plus.jpg")!)
            getPictureFromDirectory(prefix: "public/\((recies[i].recie?._name!)!)/", i: i)
        }
        
    }
    func getRecipeData(){
        self.recies.removeAll()
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                var errorMessage = "Failed to retrieve items. \(error.localizedDescription)"
                self.showAlertWithTitle(title: "Error", message: errorMessage)
            }
            else if response!.items.count == 0 {
                self.showAlertWithTitle(title: "Not Found", message: "No items match your criteria. Insert more sample data and try again.")
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBRecipe] {
                    let newRecie = recipe(recip: item)
                    self.recies.append(newRecie)
                    self.recipeCreatorPPDownloadedAtIndex.append(false)
                    self.recipeCollectionView.reloadData()
                    print(self.recies)
                }
            }
        }
        glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
    }
    
   
    func getPictureFromDirectory(prefix: String, i:Int){
        let imgCompletionHandler = {[weak self](content: AWSContent?, data: Data?, error: Error?) -> Void in
            guard self != nil else { return }
            if let error = error {
                print("Failed to download a content from a server. \(error)")
                return
            }
            print("Object download complete.")
            print("downloaded??")
            self?.recies[i].picures.append(UIImage(data: data!)!)
            DispatchQueue.main.async(execute: {
                self?.recipeCollectionView.reloadItems(at: [IndexPath(row: i, section: 0)])
            })
            print(content)
        }
        glblImageDownloadHandler.getPicture(prefix: prefix, imgCompletionHandler: imgCompletionHandler)
        
    }
    func showAlertWithTitle(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}