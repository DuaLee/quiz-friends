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
    var i = 0
    @Published var quizData = [QuizData]()
    
    struct questionStruct {
        var num: Int
        var questionS: String
        
    }
    
    var question = [questionStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session.delegate = self
        
        playerIcons = [player1, player2, player3, player4]
        answerButtons = [buttonA, buttonB, buttonC, buttonD]
        
        setupUI(gameMode: gameMode)
        
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"

        self.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                self.parse(jsonData: data)
            case .failure(let error):
                print(error)
            }
        }
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
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(QuizData.self, from: jsonData)
            
            print("Number of questions: ", decodedData.numberOfQuestions)
            numQuestions = decodedData.numberOfQuestions
            for i in 0..<numQuestions {
                question.append(questionStruct(num: decodedData.questions[i].number, questionS: decodedData.questions[i].questionSentence ))
                print("Number: ", decodedData.questions[i].number)
                print("Question: ", decodedData.questions[i].questionSentence)
                //print("Op: ", decodedData.questions[i].options.count)
            }
            //print("Question num: ", decodedData.questionNumber)
            print("Topic: ", decodedData.topic)
            print(numQuestions)
            //numQuestions = decodedData.numberOfQuestions
            
            //print("Description: ", decodedData.description)
            print("===================================")
        } catch {
            print("decode error")
        }
    }
    
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    DispatchQueue.main.async {
                        self.questionNumLabel.text = "Question \(self.question[0].num)/\(self.numQuestions)"
                        self.questionLabel.text = "\(self.question[0].questionS)"
                    }
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
}
