//
//  ViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/24/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var gameMode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            singleButton.isSelected = true
            multiButton.isSelected = false
            
            gameMode = 1
            
        case 2:
            singleButton.isSelected = false
            multiButton.isSelected = true
            
            gameMode = 2
            
        default:
            gameMode = 0
        }
        
        if gameMode > 0 {
            playButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "quizSegue":
                let controller = segue.destination as! QuizViewController
                
                controller.gameMode = self.gameMode
            default:
                break
            }
        }
    }
    
    
}
