//
//  QuizViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/24/22.
//

import UIKit
import MultipeerConnectivity

class QuizViewController: UIViewController, MCSessionDelegate {
    
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
        
        session.delegate = self
        
        playerIcons = [player1, player2, player3, player4]
        answerButtons = [buttonA, buttonB, buttonC, buttonD]
        
        setupUI(gameMode: gameMode)
        
        getJSONData()
        
    
    }
    
    func setupUI(gameMode: Int) {
        for playerIcon in playerIcons {
            playerIcon.isUserInteractionEnabled = false
            playerIcon.isEnabled = false
            playerIcon.isSelected = false
            playerIcon.setTitle("", for: .normal)
        }
        
        if gameMode == 2 {
            for index in 0..<session.connectedPeers.count {
                playerIcons[index].isEnabled = true
                playerIcons[index].setTitle("\(session.connectedPeers[index].displayName)", for: .normal)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        for answerButton in answerButtons {
            answerButton.isSelected = false
        }
        
        sender.isSelected = true
        answerSelected = sender.tag
        print(answerSelected)
    }
    
    // Asynchronous Http call to your api url, using URLSession:
    func getJSONData(){
       
       let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
        
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        
        // create a data task
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let result = data{
    
                do{
                    let json = try JSONSerialization.jsonObject(with: result, options: .fragmentsAllowed)
                    
                    if let dictionary = json as? [String:AnyObject]{
                        self.numQuestions = dictionary["numberOfQuestions"]! as! Int
                        self.readJSONData(dictionary)
                    }
                }
                catch{
                    print("Error")
                }
            }
        })
        // always call resume() to start
        task.resume()
    }

    func readJSONData(_ json: [String: AnyObject]) {
        if let questions = json["questions"] as? [[String: AnyObject]]  {
            for q in questions {
                question.append(questionStruct(num: q["number"]! as? Int, questionS: q["questionSentence"]! as? String, correctAns:q["correctOption"]! as? String))
                if  let ops = q["options"] as? [String: AnyObject]{
                    for options in ops {
                        option.append(optionStruct(letter: options.key, choice: options.value as? String))
                    }
                }
                loadQuizData()
            }
        }
    }
    
    func loadQuizData(){
        DispatchQueue.main.async {
            self.questionNumLabel.text = "Question \(self.question[0].num!)/\(self.numQuestions)"
            
            self.questionLabel.text = "\(self.question[0].questionS!)"
            
            self.buttonA.setTitle("\(self.option[0].choice!)", for: .normal)
            
            self.buttonB.setTitle("\(self.option[1].choice!)", for: .normal)
            
            self.buttonC.setTitle("\(self.option[2].choice!)", for: .normal)
            
            self.buttonD.setTitle("\(self.option[3].choice!)", for: .normal)
        }
    }
    @IBAction func aPressed(_ sender: UIButton) {
        print("\(self.option[0].letter!) \(self.option[0].choice!)")
        
        if self.option[0].letter! == self.question[0].correctAns!{
            question.remove(at: 0)
            option.removeSubrange(0...3)
            if 0 < question.count {
                loadQuizData()
            }
        }
    }
   
    @IBAction func bPressed(_ sender: UIButton) {
        print("\(self.option[1].letter!) \(self.option[1].choice!)")
        if self.option[1].letter! == self.question[0].correctAns!{
            question.remove(at: 0)
            option.removeSubrange(0...3)
            if 0 < question.count {
                loadQuizData()
            }
        }
    }
   
    @IBAction func cPressed(_ sender: UIButton) {
        print("\(self.option[2].letter!) \(self.option[2].choice!)")
        if self.option[2].letter! == self.question[0].correctAns!{
            question.remove(at: 0)
            option.removeSubrange(0...3)
            if 0 < question.count {
                loadQuizData()
            }
        }
    }
   
    @IBAction func dPressed(_ sender: UIButton) {
        print("\(self.option[3].letter!) \(self.option[3].choice!)")
        if self.option[3].letter! == self.question[0].correctAns!{
            question.remove(at: 0)
            option.removeSubrange(0...3)
            if 0 < question.count {
                loadQuizData()
            }
        }
    }
}
