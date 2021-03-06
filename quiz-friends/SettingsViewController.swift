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
var shakeSetting = false
var retainSetting = false

class SettingsViewController: UIViewController {

    @IBOutlet weak var tiltButton: UIButton!
    @IBOutlet weak var hapticButton: UIButton!
    @IBOutlet weak var shakeButton: UIButton!
    @IBOutlet weak var retainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tiltButton.setTitle(" Enable Tilt to Answer", for: .normal)
        tiltButton.setTitle(" Disable Tilt to Answer", for: .selected)
        
        hapticButton.setTitle(" Enable Haptic Feedback", for: .normal)
        hapticButton.setTitle(" Disable Haptic Feedback", for: .selected)
        
        shakeButton.setTitle(" Enable Shake to Roulette", for: .normal)
        shakeButton.setTitle(" Disable Shake to Roulette", for: .selected)

        retainButton.setTitle(" Enable Retain Score Each Round", for: .normal)
        retainButton.setTitle(" Disable Retain Score Each Round", for: .selected)
        
        if tiltSetting {
            tiltButton.isSelected = true
        }
        
        if hapticSetting {
            hapticButton.isSelected = true
        }
        
        if shakeSetting {
            shakeButton.isSelected = true
        }
        
        if retainSetting {
            retainButton.isSelected = true
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            
            switch sender.tag {
            case 1:
                tiltSetting = false
                
            case 2:
                hapticSetting = false
                
            case 3:
                shakeSetting = false
                
            case 4:
                retainSetting = false
                
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
                
            case 3:
                shakeSetting = true
                
            case 4:
                retainSetting = true
                
            default:
                break
            }
        }
        
        if hapticSetting {
            AudioServicesPlaySystemSound(1519)
        }
    }
}
