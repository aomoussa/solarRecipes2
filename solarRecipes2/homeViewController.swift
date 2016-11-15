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
    
    @IBOutlet weak var addRecipeButton: UIButton!
    @IBOutlet weak var addOvenButton: UIButton!
    @IBAction func addClicked(_ sender: UIButton) {
        addRecipeButton.alpha = 1
        addOvenButton.alpha = 1
    }
    //----------- ---------------- -------------- local variables ------------ ----------- ----------- start
    var recies = [recipe]()
    
    var searchMode = false
    
    private var manager: AWSUserFileManager!
    
    //----------- ---------------- -------------- local variables ------------ ----------- ----------- end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRecipeButton.alpha = 0
        addOvenButton.alpha = 0
        recipeCollectionView.delegate = self
        recipeCollectionView.dataSource = self
        addRefresherToCollectionView()
        
        getRecipeData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //---------- ----------- ---------- search mode activation and deactivation ---------- ---------- starts
    @IBAction func searchClicked(_ sender: UIButton) {
        if(searchMode){
            deactivateSearchMode()
        }
        else{
            activateSearchMode()
        }
    }
    func activateSearchMode(){
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        self.recipeCollectionView.frame = CGRect(x: 0, y: screenHeight*0.5, width: screenWidth, height: screenHeight*0.4)
        searchMode = true
    }
    func deactivateSearchMode(){
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        self.recipeCollectionView.frame = CGRect(x: 0, y: screenHeight*0.1, width: screenWidth, height: screenHeight*0.8)
        searchMode = false
        self.view.endEditing(true)
    }
    //---------- ----------- ---------- search mode activation and deactivation ---------- ---------- ends
    
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- starts
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return recies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! recipeCollectionViewCell
        if(indexPath.row < recies.count){
        cell.recipeNameLabel.text = recies[indexPath.row].recie?._name
        cell.tempValueLabel.text = String(describing: (recies[indexPath.row].recie?._temperature)!)
        cell.durValueLabel.text = String(describing: (recies[indexPath.row].recie?._duration)!)
        if( recies[indexPath.row].picures.count > 1){
            cell.recipeImageView.image = recies[indexPath.row].picures[1]
        }
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
        return CGSize(width: screenWidth/2.1, height: screenHeight/2.5)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        populatePicturesAtIndex(i: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toRecipeDetails", sender: recies[indexPath.row])
    }
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
    func populatePicturesAtIndex(i: Int){
        
        if(i < recies.count && recies[i].picures.count == 0){
            recies[i].picures.append(UIImage(named: "plus.jpg")!)
            getPictureFromDirectory(prefix: "public/\((recies[i].recie?._name!)!)/", i: i)
        }
        
    }
    func addRefresherToCollectionView(){
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeViewController.refresherReload(_:)), for: UIControlEvents.valueChanged)
        recipeCollectionView.addSubview(refresher)
    }
    func refresherReload(_ sender: UIRefreshControl){
        var tempRecies = [recipe]()
        //self.recies.removeAll()
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                let errorMessage = "Failed to retrieve items. \(error.localizedDescription)"
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
                    tempRecies.append(newRecie)
                    print(tempRecies)
                }
                DispatchQueue.main.async(execute: {
                    self.recies = tempRecies
                    self.recipeCollectionView.reloadData()
                    sender.endRefreshing()
                })
            }
        }
        glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
        /*
        self.recipeCollectionView.performBatchUpdates({
            glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
            }) { (completed) in
                DispatchQueue.main.async(execute: {
                    self.recipeCollectionView.reloadData()
                    sender.endRefreshing()
                })
        }*/
        
    }
    func getRecipeData(){
        self.recies.removeAll()
        let x = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        x.center = self.view.center
        x.startAnimating()
        self.view.addSubview(x)
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                let errorMessage = "Failed to retrieve items. \(error.localizedDescription)"
                self.showAlertWithTitle(title: "Error", message: errorMessage)
                x.removeFromSuperview()
            }
            else if response!.items.count == 0 {
                self.showAlertWithTitle(title: "Not Found", message: "No items match your criteria. Insert more sample data and try again.")
                x.removeFromSuperview()
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBRecipe] {
                    let newRecie = recipe(recip: item)
                    self.recies.append(newRecie)
                    print(self.recies)
                }
                DispatchQueue.main.async(execute: {
                    self.recipeCollectionView.reloadData()
                    x.removeFromSuperview()
                })
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toRecipeDetails"){
            let destVC = segue.destination as! recipeDetailsViewController
            destVC.recie1 = (sender as? recipe)!
            
        }
    }
    func showAlertWithTitle(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let reloadAction: UIAlertAction = UIAlertAction(title: "Reload", style: .default, handler: {alertController in self.getRecipeData()})
        alertController.addAction(cancelAction)
        alertController.addAction(reloadAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
