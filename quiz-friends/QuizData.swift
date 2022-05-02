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

struct QuestionData: Decodable {
    
    let number: Int
    let questionSentence: String
    let options: String
    let correctOption: String
}

struct OptionData: Decodable {
     let optionLetter: String
     let optionSentence: String
   
}
