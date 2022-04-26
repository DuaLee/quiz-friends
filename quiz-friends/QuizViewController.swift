//
//  QuizViewController.swift
//  quiz-friends
//
//  Created by Lannah Bell on 4/25/22.
//

import UIKit

class QuizViewController: UIViewController {
    
    var gameMode: Int = 0
    var numQuestions = [Int]()
    @IBOutlet weak var questionLabel: UILabel!
    @Published var quizData = [QuizData]()
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
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
        // Do any additional setup after loading the view.
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(QuizData.self, from: jsonData)
            
            print("Number of questions: ", decodedData.numberOfQuestions)
            numQuestions.append(decodedData.numberOfQuestions)
           // print("Questions: ", decodedData.questions)
            //print("Question num: ", decodedData.questionNumber)
            print("Topic: ", decodedData.topic)
            print(numQuestions)
           // numQuestions = decodedData.numberOfQuestions
            
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
                        self.questionLabel.text = "Question 0/\(self.numQuestions[0])"
                    } 
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
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

}
