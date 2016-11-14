//
//  recipeDetailsViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/13/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit

class recipeDetailsViewController: UIViewController {
    
    var recie1 = recipe()

    @IBOutlet weak var ingredientsTableView: UITableView!
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var recipeTitleLabel: UILabel!
    
    @IBOutlet weak var creatorNameLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var ingredientsButton: UIButton!
    
    @IBOutlet weak var directionsButton: UIButton!
    
    @IBAction func ingredientsClicked(_ sender: UIButton) {
    }
    
    @IBAction func directionsClicked(_ sender: UIButton) {
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRecipeStuff(recie1: recie1)
    }
    func setRecipeStuff(recie1: recipe){
        if(recie1.picures.count > 1){
            recipeImageView.image = recie1.picures[1]
        }
        recipeTitleLabel.text = recie1.recie?._name
        creatorNameLabel.text = "By \((recie1.recie?._creatorName)!)"
        difficultyLabel.text = "hard"
        durationLabel.text = String(describing: (recie1.recie?._duration)!)
        temperatureLabel.text = String(describing: (recie1.recie?._temperature)!)
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
