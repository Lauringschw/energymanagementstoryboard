//
//  ViewController.swift
//  energymanagementstoryboard
//
//  Created by Laurin Gschwenter on 15.09.24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var btn_select_feeling: UIButton!
    @IBOutlet weak var btn_select_mode: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add rounded corners and border for the feeling button
        self.btn_select_feeling.layer.cornerRadius = 12
        self.btn_select_feeling.layer.borderWidth = 5
        self.btn_select_feeling.layer.borderColor = UIColor.orange.cgColor
        self.btn_select_feeling.backgroundColor = UIColor.orange
        self.btn_select_feeling.clipsToBounds = true
    }
    
    @IBAction func optionFeelingSelection(_ sender: Any) {
        if let button = sender as? UIButton {
            // Handle UIButton case (if needed)
            guard let feeling = button.title(for: .normal) else { return }
            print(feeling)
        } else if let command = sender as? UICommand {
            // Handle UICommand case (for pull-down menu options)
            let feeling = command.title
            print("Selected feeling: \(feeling)")
            
            // Update the button's title based on the selected feeling
            self.btn_select_feeling.setTitle(feeling, for: .normal)
            
            // Change the button color and border color based on the selected feeling
            switch feeling {
            case "Too Warm":
                self.btn_select_feeling.backgroundColor = UIColor.red
                self.btn_select_feeling.layer.borderColor = UIColor.red.cgColor // Change border color to red
            case "A Little Warm":
                self.btn_select_feeling.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5) // light red
                self.btn_select_feeling.layer.borderColor = UIColor.systemRed.cgColor // Border color to light red
            case "Perfect":
                self.btn_select_feeling.backgroundColor = UIColor.green
                self.btn_select_feeling.layer.borderColor = UIColor.green.cgColor // Border color to green
            case "A Little Cold":
                self.btn_select_feeling.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5) // light blue
                self.btn_select_feeling.layer.borderColor = UIColor.systemBlue.cgColor // Border color to light blue
            case "Too Cold":
                self.btn_select_feeling.backgroundColor = UIColor.blue
                self.btn_select_feeling.layer.borderColor = UIColor.blue.cgColor // Border color to blue
            default:
                self.btn_select_feeling.backgroundColor = UIColor.orange
                self.btn_select_feeling.layer.borderColor = UIColor.orange.cgColor // Default orange border
            }
            
            // Add border when a feeling is selected
            self.btn_select_feeling.layer.borderWidth = 3
            self.btn_select_feeling.layer.cornerRadius = 12 // Adjust as necessary
            self.btn_select_feeling.clipsToBounds = true
        } else {
            print("Unknown sender type")
        }
    }
    
    @IBAction func optionModeSelection(_ sender: Any) {
        if let button = sender as? UIButton {
            // Handle UIButton case
            guard let mode = button.title(for: .normal) else { return }
            print("Selected mode: \(mode)")
            self.btn_select_mode.setTitle(mode, for: .normal)
        } else if let command = sender as? UICommand {
            // Handle UICommand case (for pull-down menu options)
            let mode = command.title
            print("Selected mode: \(mode)")
            self.btn_select_mode.setTitle(mode, for: .normal)
            
            // No border modifications for mode button
        } else {
            print("Unknown sender type")
        }
    }
}
