//
//  userSettingsViewController.swift
//  Pods
//
//  Created by Ahmed Moussa on 11/13/16.
//
//


import UIKit
import FacebookLogin
import FacebookCore
import AWSMobileHubHelper

class userSettingsViewController: UIViewController {
    
    @IBOutlet weak var userRecipesCollectionView: UICollectionView!
    
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        if let accessToken = AccessToken.current {
            let loginManager = LoginManager()
            loginManager.logOut()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        else{
            print("you were never logged in? this shouldn't happen i think")
        }
    }
    
    
    var FBID = ""
    var FBName = ""
    
    override func viewDidLoad() {
        
        
        //let userNameLabel = UILabel()
        if AccessToken.current != nil {
            getFBProfile(accessToken: AccessToken.current!)
        }
        
    }
    
    func getFBProfile(accessToken: AccessToken){
        let req = GraphRequest(graphPath: "me", parameters: ["fields":"name"], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        req.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue)
                print(value.stringValue)
                print(value.arrayValue)
                
                self.FBID = value.dictionaryValue!["id"] as! String //["id"] //(forKey: "id")
                self.FBName = value.dictionaryValue!["name"] as! String
                print(self.FBID)
                print(self.FBName)
                self.usernameLabel.text = self.FBName
                self.getFBProfilePic(userFBID: self.FBID)
            //print(value.dictionaryValue)
            case .failed(let error):
                print(error)
            }
        }
    }
    func getFBProfilePic(userFBID: String){
        let ahmedsPicURL = URL(string: "https://graph.facebook.com/10155692326063868/picture?type=large")
        let picURL = URL(string: "https://graph.facebook.com/\(userFBID)/picture?type=large")
        print(picURL)
        
        let activityInd = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityInd.startAnimating()
        activityInd.center = profilePictureButton.center
        self.view.addSubview(activityInd)
        
        
        print("Download Started")
        getDataFromUrl(url: picURL!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? picURL?.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                self.profilePictureButton.contentMode = .scaleAspectFill
                self.profilePictureButton.setImage(image, for: UIControlState.normal)
                let imageView = UIImageView(image: image)
                imageView.frame = self.profilePictureButton.frame
                imageView.contentMode = .scaleAspectFit
                self.view.addSubview(imageView)
                activityInd.removeFromSuperview()
            }
        }
        
    }
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
