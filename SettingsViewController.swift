//
//  SettingsViewController.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 28/03/24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var swPlay: UISwitch!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        swPlay.isOn = UserDefaults.standard.bool(forKey: "play")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changePlay(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "play")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
