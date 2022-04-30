//
//  QuizData.swift
//  quiz-friends
//
//  Created by Lannah Bell on 4/26/22.
//

import Foundation

struct QuizData: Decodable {
    let numberOfQuestions: Int
    //let questions: String
    let topic: String
    //var questionNumber: Int
}

struct QuestionData: Codable {
    
    //let question: String
    //let options: OptionData
    //let correctOption: String
}

struct OptionData: Codable {
    let optionLetter: String
    let optionWord: String
    let topic: String
}
