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

class QuizViewController: UIViewController, MCSessionDelegate, CAAnimationDelegate {
    
    // MARK: Color Constants
    let correctColor = UIColor.systemCyan
    let incorrectColor = UIColor.systemPink
    let noAnswerColor = UIColor.systemYellow
    let defaultColor = UIColor.systemGray
    //
    
    // MARK: Score Constants (Default: Jeopardy Style)
    let correctAward = 1.0 // default: 1.0
    let incorrectAward = -1.0 // default: -1.0
    let noAnswerAward = 0.0 // default: 0.0
    
    // MARK: Timer Constants (seconds)
    let questionTime: TimeInterval = 5 // default: 10
    let reviewTime: TimeInterval = 3 // default: 3
    //
    
    // MARK: JSON Source Constants
    let endIndex = 3
    //
    
    @IBOutlet weak var quizTitle: UINavigationItem!
    weak var parentVC: ViewController?
    
    @IBOutlet weak var player1: UIButton!
    @IBOutlet weak var player2: UIButton!
    @IBOutlet weak var player3: UIButton!
    @IBOutlet weak var player4: UIButton!
    var playerIcons: [UIButton] = []
    
    @IBOutlet weak var status1: UILabel!
    @IBOutlet weak var status2: UILabel!
    @IBOutlet weak var status3: UILabel!
    @IBOutlet weak var status4: UILabel!
    var statusLabels: [UILabel] = []
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    var answerButtons: [UIButton] = []
    
    @IBOutlet weak var restartButton: UIButton!
    
    var answerSelected = 0
    var quizID = 1
    var playerScore = PlayerScore()
    
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var myScoreLabel: UILabel!
    @IBOutlet weak var otherScoreLabel: UILabel!
    
    var gameMode: Int = 0
    var isHost: Bool = false
    
    var myPeerID: MCPeerID!
    var session: MCSession!
    var startingPeers: [MCPeerID] = []
    
    var coreMotionManager = CMMotionManager()
    var tiltTimer = Timer()
    var startingSet = false
    var startingX = 0.0
    var startingY = 0.0
    
    var numQuestions = 0
    var qTitle = ""

    struct Question {
        var num: Int?
        var questionS: String?
        var correctAns: String?
    }
    
    struct QuestionOption {
        var letter: String?
        var choice: String?
    }
    
    var question = [Question]()
    var option = [QuestionOption]()
    
    @IBOutlet weak var endingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getJSONData()
        
        startingPeers = session.connectedPeers
        
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        session.delegate = self
        
        playerIcons = [player1, player2, player3, player4]
        statusLabels = [status1, status2, status3, status4]
        answerButtons = [buttonA, buttonB, buttonC, buttonD]
        
        playerScore.displayName = myPeerID.displayName
        
        if !retainSetting {
            playerScore.score = 0
        }
        
        setupUI(gameMode: gameMode)
        drawTimer()
        
        if tiltSetting {
            setupTilt()
        }
    }
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    func drawTimer() {
        var center = view.center
        center.y -= 30
        
        let circularPath = UIBezierPath(arcCenter: center, radius: view.frame.width * 0.2, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = CGColor(red: 0.9, green: 0.5, blue: 0.7, alpha: 0.3)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        
        view.layer.insertSublayer(shapeLayer, at: 0)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = CGColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 20
        trackLayer.lineCap = .round
        
        view.layer.insertSublayer(trackLayer, at: 0)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.delegate = self
        
        basicAnimation.toValue = 1
        basicAnimation.duration = questionTime
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "circle")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        for answerButton in answerButtons {
            answerButton.isEnabled = false
        }
        
        var trigger = Data()
        
        //print("answerSelected \(answerSelected)")
        
        if answerSelected > 0 {
            //print("something selected")
            trigger = option[answerSelected - 1].letter!.data(using: .utf8, allowLossyConversion: false)!
            
            if option[answerSelected - 1].letter! == question[0].correctAns! {
                statusLabels[0].textColor = correctColor
                playerScore.score += correctAward
            } else {
                statusLabels[0].textColor = incorrectColor
                playerScore.score += incorrectAward
            }
        } else {
            trigger = "0".data(using: .utf8, allowLossyConversion: false)!
        
            statusLabels[0].textColor = noAnswerColor
            playerScore.score += noAnswerAward
        }
        
        do {
            try session.send(trigger, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            //print(error)
        }
        
        Timer.scheduledTimer(withTimeInterval: reviewTime, repeats: false) { [self] _ in
            question.remove(at: 0)
            option.removeSubrange(0...3)
            
            if question.count > 0 {
                shapeLayer.removeAnimation(forKey: "circle")
                drawTimer()
                
                for answerButton in answerButtons {
                    answerButton.isSelected = false
                    answerButton.isEnabled = true
                }
                for playerIcon in playerIcons {
                    playerIcon.isSelected = false
                }
                for statusLabel in statusLabels {
                    statusLabel.textColor = defaultColor
                }
                
                loadQuizData()
            } else {
                endingView.isHidden = false
                questionNumLabel.isHidden = true
                
                myScoreLabel.text = "You scored: \(playerScore.score)"
                
                if gameMode == 2 {
                    otherScoreLabel.isHidden = false
                    
                    let trigger = "- \(playerScore.description)".data(using: .utf8, allowLossyConversion: false)
                    
                    do {
                        try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
                    } catch {
                        //print(error)
                    }
                }
                
                if isHost || gameMode == 1 {
                    restartButton.isEnabled = true
                }
                
                for answerButton in answerButtons {
                    answerButton.isEnabled = false
                    answerButton.setTitle("", for: .normal)
                }
                
                option.removeAll()
                question.removeAll()
                
                numQuestions = 0
                
                tiltTimer.invalidate()
                
                //print(option.count)
            }
            
            answerSelected = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        parentVC!.viewDidLoad()
        
        tiltTimer.invalidate()
        
        let trigger = "disconnect".data(using: .utf8, allowLossyConversion: false)
        
        do {
            try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            //print(error)
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
        restartButton.isSelected = false
        
        endingView.isHidden = true
        questionNumLabel.isHidden = false
        
        myScoreLabel.text = ""
        otherScoreLabel.text = ""
        
        for playerIcon in playerIcons {
            playerIcon.isUserInteractionEnabled = false
            playerIcon.isEnabled = false
            playerIcon.isSelected = false
            playerIcon.setTitle("", for: .normal)
            playerIcon.setImage(nil, for: .normal)
        }
        
        for statusLabel in statusLabels {
            statusLabel.textColor = defaultColor
            statusLabel.text = ""
        }
        
        playerIcons[0].setTitle(myPeerID.displayName, for: .normal)
        playerIcons[0].isEnabled = true
        statusLabels[0].text = "⬤"
        
        if gameMode == 2 {
            for index in 0..<session.connectedPeers.count {
                playerIcons[index + 1].isEnabled = true
                playerIcons[index + 1].setTitle("\(session.connectedPeers[index].displayName)", for: .normal)
                statusLabels[index + 1].text = "⬤"
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dataString = String(decoding: data, as: UTF8.self)
        //print("dataString \(dataString)")
        
        if dataString == "restart" {
            DispatchQueue.main.async { [self] in
                restart(restartButton)
            }
        } else if dataString.starts(with: "-") {
            //print(dataString)
            DispatchQueue.main.async { [self] in
                otherScoreLabel.text?.append("\n\(dataString)")
            }
        } else if let playerIndex = startingPeers.firstIndex(of: peerID) {
            if dataString == "disconnect" {
                DispatchQueue.main.async { [self] in
                    playerIcons[playerIndex + 1].isEnabled = false
                    playerIcons[playerIndex + 1].setTitle("", for: .normal)
                    playerIcons[playerIndex + 1].setImage(UIImage(systemName: "wifi.slash"), for: .normal)
                }
            } else if dataString == "selected" {
                DispatchQueue.main.async { [self] in
                    playerIcons[playerIndex + 1].isSelected = true
                }
            } else if ["A", "B", "C", "D"].contains(dataString) {
                DispatchQueue.main.async { [self] in
                    if dataString == question[0].correctAns! {
                        statusLabels[playerIndex + 1].textColor = correctColor
                        //print("correct")
                    } else {
                        statusLabels[playerIndex + 1].textColor = incorrectColor
                        //print("incorrect")
                    }
                }
            } else if dataString == "0" {
                DispatchQueue.main.async { [self] in
                    statusLabels[playerIndex + 1].textColor = noAnswerColor
                    //print("empty")
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
            
            let trigger = "selected".data(using: .utf8, allowLossyConversion: false)
            
            do {
                try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                //print(error)
            }
        }
    }
    
    func setupTilt() {
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
    
    func tiltButton(answerChoice: Int) {
        if hapticSetting && answerChoice != answerSelected {
            AudioServicesPlaySystemSound(1519)
        }
        
        for answerButton in answerButtons {
            answerButton.isSelected = false
        }
        
        answerButtons[answerChoice - 1].isSelected = true
        answerSelected = answerChoice
        
        if question.count != 0 {
            broadcastAnswer()
        }
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
        
        if question.count != 0 {
            broadcastAnswer()
        }
    }
    
    // MARK: Asynchronous Http call to api url, using URLSession:
    func getJSONData() {
       
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz\(quizID).json"
        let url = URL(string: urlString)
        
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let result = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: result, options: .fragmentsAllowed)
                    
                    if let dictionary = json as? [String:AnyObject] {
                        self.numQuestions = dictionary["numberOfQuestions"]! as! Int
                        self.qTitle = dictionary["topic"]! as! String
                        self.readJSONData(dictionary)
                    }
                } catch {
                    //print("Error")
                }
            }
        })
        
        task.resume()
    }

    func readJSONData(_ json: [String: AnyObject]) {
        if let questions = json["questions"] as? [[String: AnyObject]] {
            for q in questions {
                question.append(Question(num: q["number"]! as? Int, questionS: q["questionSentence"]! as? String, correctAns:q["correctOption"]! as? String))
                if let ops = q["options"] as? [String: AnyObject] {
                    for options in ops {
                        option.append(QuestionOption(letter: options.key, choice: options.value as? String))
                    }
                }
                
                loadQuizData()
            }
        }
    }
    
    func loadQuizData() {
        DispatchQueue.main.async {
            self.questionNumLabel.text = "Question \(self.question[0].num!)/\(self.numQuestions)"
            
            self.quizTitle.title = "\(self.qTitle)"
            
            self.questionLabel.text = "\(self.question[0].questionS!)"
            
            self.buttonA.setTitle("\(self.option[0].choice!)", for: .normal)
            
            self.buttonB.setTitle("\(self.option[1].choice!)", for: .normal)
            
            self.buttonC.setTitle("\(self.option[2].choice!)", for: .normal)
            
            self.buttonD.setTitle("\(self.option[3].choice!)", for: .normal)
        }
    }
    
    @IBAction func restart(_ sender: UIButton) {
        if quizID < endIndex {
            quizID += 1
        } else {
            quizID = 1
        }
        
        for answerButton in answerButtons {
            answerButton.isEnabled = true
        }
        
        endingView.isHidden = true
        
        // MARK: if is host session send restart command to other clients. only show restart button to host. grab isHost from viewcontroller segue //
        if isHost {
            let trigger = "restart".data(using: .utf8, allowLossyConversion: false)
            
            do {
                try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                //print(error)
            }
        }
        
        viewDidLoad()
    }
}
