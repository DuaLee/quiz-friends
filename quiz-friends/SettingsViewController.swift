//
//  SettingsViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/26/22.
//

import UIKit
import AudioToolbox

var tiltSetting = false
var hapticSetting = false

class SettingsViewController: UIViewController {

    @IBOutlet weak var tiltButton: UIButton!
    @IBOutlet weak var hapticButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tiltButton.setTitle(" Enable Tilt to Answer", for: .normal)
        tiltButton.setTitle(" Disable Tilt to Answer", for: .selected)
        
        hapticButton.setTitle(" Enable Haptic Feedback", for: .normal)
        hapticButton.setTitle(" Disable Haptic Feedback", for: .selected)

        if tiltSetting {
            tiltButton.isSelected = true
        }
        
        if hapticSetting {
            hapticButton.isSelected = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            
            switch sender.tag {
            case 1:
                tiltSetting = false
                
            case 2:
                hapticSetting = false
                
            default:
                break
            }
        } else {
            sender.isSelected = true
            
            switch sender.tag {
            case 1:
                tiltSetting = true
                
            case 2:
                hapticSetting = true
                AudioServicesPlaySystemSound(4095)
                
            default:
                break
            }
        }
    }
}
