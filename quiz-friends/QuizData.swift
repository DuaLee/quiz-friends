//
//  QuizData.swift
//  quiz-friends
//
//  Created by Lannah Bell on 4/26/22.
//

import Foundation

struct QuizData: Decodable {
    let numberOfQuestions: Int
    let questions: [QuestionData]
    let topic: String
    //var questionNumber: Int
}

struct QuestionData: Codable {
    
    let number: Int
    let questionSentence: String
   // let options: [OptionData]
    
}

struct OptionData: Codable {
    //let optionLetter: String
   // let optionWord: String
   // let correctOption: String
}
