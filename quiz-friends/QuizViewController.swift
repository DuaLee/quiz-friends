//
//  QuizViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/24/22.
//

import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var player1: UIButton!
    @IBOutlet weak var player2: UIButton!
    @IBOutlet weak var player3: UIButton!
    @IBOutlet weak var player4: UIButton!
    var playerIcons: [UIButton] = []
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    var gameMode: Int = 0
    
    var numQuestions = 0
    @Published var quizData = [QuizData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        playerIcons = [player1, player2, player3, player4]
//
//        for playerIcon in playerIcons {
//            playerIcon.isUserInteractionEnabled = false
//            playerIcon.isSelected = false
//            playerIcon.setTitle("", for: .normal)
//        }
      
        // questionLabel.text = "Question 0/\(numQuestions[0])"
        
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"

        self.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                self.parse(jsonData: data)
            case .failure(let error):
                print(error)
            }
        }
        
        print(gameMode)
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(QuizData.self, from: jsonData)
            
            print("Number of questions: ", decodedData.numberOfQuestions)
            numQuestions = decodedData.numberOfQuestions
            //print("Questions: ", decodedData.questions)
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
                        self.questionLabel.text = "Question 0/\(self.numQuestions)"
                    }
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
}
