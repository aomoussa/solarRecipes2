//
//  ViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class loginViewController: UIViewController {

    @IBOutlet weak var FBLoginButton: UIButton!
    
    @IBAction func bypassLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toHome", sender: self)
    }
    @IBAction func FBLoginClicked(_ sender: UIButton) {
        
        if let accessToken = AccessToken.current {
            self.performSegue(withIdentifier: "toHome", sender: self)
        }
        else{
            let loginManager = LoginManager()
            loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                    self.performSegue(withIdentifier: "toHome", sender: self)
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in!")
                    self.performSegue(withIdentifier: "toHome", sender: self)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

