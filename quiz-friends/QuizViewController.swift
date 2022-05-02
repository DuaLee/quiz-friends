//
//  QuizViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/24/22.
//

import UIKit
import MultipeerConnectivity
import CoreMotion
import AudioToolbox

class QuizViewController: UIViewController, MCSessionDelegate {
    
    weak var parentVC: ViewController?
    
    @IBOutlet weak var player1: UIButton!
    @IBOutlet weak var player2: UIButton!
    @IBOutlet weak var player3: UIButton!
    @IBOutlet weak var player4: UIButton!
    var playerIcons: [UIButton] = []
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    var answerButtons: [UIButton] = []
    
    var answerSelected = 0
    
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var gameMode: Int = 0
    
    var myPeerID: MCPeerID!
    var session: MCSession!
    var startingPeers: [MCPeerID] = []
    
    var coreMotionManager = CMMotionManager()
    var tiltTimer = Timer()
    var startingSet = false
    var startingX = 0.0
    var startingY = 0.0
    
    var numQuestions = 0

    struct questionStruct {
        var num: Int?
        var questionS: String?
        var correctAns: String?
    }
    
    struct optionStruct {
        var letter: String?
        var choice: String?
    }
    
    var question = [questionStruct]()
    var option = [optionStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingPeers = session.connectedPeers
        
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        session.delegate = self
        
        playerIcons = [player1, player2, player3, player4]
        answerButtons = [buttonA, buttonB, buttonC, buttonD]
        
        setupUI(gameMode: gameMode)
        
        if tiltSetting {
            coreMotionManager.startAccelerometerUpdates()
            
            tiltTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
                if let data = self.coreMotionManager.accelerometerData {
                    if !startingSet {
                        startingX = data.acceleration.x
                        startingY = data.acceleration.y
                        
                        startingSet = true
                    } else {
                        let x = data.acceleration.x - startingX
                        let y = data.acceleration.y - startingY

                        //print(x, y)

                        if x > 0.2 {
                            tiltButton(answerChoice: 4)
                        } else if x < -0.2 {
                            tiltButton(answerChoice: 3)
                        } else if y > 0.2 {
                            tiltButton(answerChoice: 1)
                        } else if y < -0.2 {
                            tiltButton(answerChoice: 2)
                        }
                    }
                }
            }
        }
        
        getJSONData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        parentVC!.viewDidLoad()
        
        tiltTimer.invalidate()
        
        let trigger = "disconnect".data(using: .utf8, allowLossyConversion: false)
        
        do {
            try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session.disconnect()
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake && shakeSetting {
            if hapticSetting {
                AudioServicesPlaySystemSound(1521)
            }
            
            let randomAnswer = Int.random(in: 1...4)
            
            tiltButton(answerChoice: randomAnswer)
        }
    }
    
    func setupUI(gameMode: Int) {
        for playerIcon in playerIcons {
            playerIcon.isUserInteractionEnabled = false
            playerIcon.isEnabled = false
            playerIcon.isSelected = false
            playerIcon.setTitle("", for: .normal)
        }
        
        playerIcons[0].setTitle(myPeerID.displayName, for: .normal)
        playerIcons[0].isEnabled = true
        
        if gameMode == 2 {
            for index in 0..<session.connectedPeers.count {
                playerIcons[index + 1].isEnabled = true
                playerIcons[index + 1].setTitle("\(session.connectedPeers[index].displayName)", for: .normal)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dataString = String(decoding: data, as: UTF8.self)
        print(dataString)
        
        if let playerIndex = startingPeers.firstIndex(of: peerID) {
            if dataString == "disconnect" {
                DispatchQueue.main.async { [self] in
                    playerIcons[playerIndex + 1].isEnabled = false
                    playerIcons[playerIndex + 1].setTitle("", for: .normal)
                    playerIcons[playerIndex + 1].setImage(UIImage(systemName: "wifi.slash"), for: .normal)
                }
            } else {
                DispatchQueue.main.async { [self] in
                    playerIcons[playerIndex + 1].isSelected = true
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func broadcastAnswer() {
        if answerSelected != 0 {
            playerIcons[0].isSelected = true
            
            let trigger = "\(answerSelected)".data(using: .utf8, allowLossyConversion: false)
            
            do {
                try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                //print(error)
            }
        }
        
        if self.option[answerSelected - 1].letter! == self.question[0].correctAns! {
            question.remove(at: 0)
            option.removeSubrange(0...3)
            
            if 0 < question.count {
                loadQuizData()
            }
        }
    }
    
    func tiltButton(answerChoice: Int) {
        if hapticSetting && answerChoice != answerSelected {
            AudioServicesPlaySystemSound(1519)
        }
        
        for answerButton in answerButtons {
            answerButton.isSelected = false
        }
        
        answerButtons[answerChoice - 1].isSelected = true
        answerSelected = answerChoice
        
        broadcastAnswer()
    }
    
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        if hapticSetting {
            AudioServicesPlaySystemSound(1519)
        }
        
        for answerButton in answerButtons {
            answerButton.isSelected = false
        }
        
        sender.isSelected = true
        answerSelected = sender.tag
        
        broadcastAnswer()
    }
    
    // MARK: Asynchronous Http call to api url, using URLSession:
    func getJSONData() {
       
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
        let url = URL(string: urlString)
        
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let result = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: result, options: .fragmentsAllowed)
                    
                    if let dictionary = json as? [String:AnyObject] {
                        self.numQuestions = dictionary["numberOfQuestions"]! as! Int
                        self.readJSONData(dictionary)
                    }
                } catch {
                    print("Error")
                }
            }
        })
        
        task.resume()
    }

    func readJSONData(_ json: [String: AnyObject]) {
        if let questions = json["questions"] as? [[String: AnyObject]] {
            for q in questions {
                question.append(questionStruct(num: q["number"]! as? Int, questionS: q["questionSentence"]! as? String, correctAns:q["correctOption"]! as? String))
                if let ops = q["options"] as? [String: AnyObject] {
                    for options in ops {
                        option.append(optionStruct(letter: options.key, choice: options.value as? String))
                    }
                }
                
                loadQuizData()
            }
        }
    }
    
    func loadQuizData() {
        DispatchQueue.main.async {
            self.questionNumLabel.text = "Question \(self.question[0].num!)/\(self.numQuestions)"
            
            self.questionLabel.text = "\(self.question[0].questionS!)"
            
            self.buttonA.setTitle("\(self.option[0].choice!)", for: .normal)
            
            self.buttonB.setTitle("\(self.option[1].choice!)", for: .normal)
            
            self.buttonC.setTitle("\(self.option[2].choice!)", for: .normal)
            
            self.buttonD.setTitle("\(self.option[3].choice!)", for: .normal)
        }
    }
}
