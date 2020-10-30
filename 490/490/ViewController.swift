//
//  ViewController.swift
//  490
//
//  Created by Hannah  Keefe  on 2020-10-14.
//

import UIKit

// view controller building class building off subclass UIViewController
class ViewController: UIViewController {

    @IBOutlet weak var AppTitle: UILabel!
    
    
    @IBOutlet weak var PickMood: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
  
    @IBAction func Happy(_ sender: Any) {
        print("deal tapped")
        // this just means that the button that you are tapping will chanhe to image card5//
        //leftImageview.image = UIImage(named: "card5")
    }
    
}

