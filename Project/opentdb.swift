//
//  opentdb.swift
//  Project
//
//  Created by Oscar Stenqvist on 2018-11-03.
//  Copyright © 2018 Oscar Stenqvist. All rights reserved.
//

import Foundation
import UIKit


struct question {
    let difficulty : String
    let category : String
    let question : String
    let correct_answer : String
    let incorrect_answers : [String]
    
}
/* Contains functions for cummunication with the opentdb database
 - getQuestions() -> Void gets 10 new questions and puts them in the class variable questions
 
 TODO:
 - getNQuestions(nrOfQuestions) //get anny number of questions
 - getDifficulty(nrOfQuestions, difficulty) //get anny number of questions and specific difficulty
 
 */
class opentdb {

    // MARK: -Variables
    private var IsDataReady : Bool = false
    
    private var offlineMode : Bool = false
    
    private var offlineDataReady : Bool = false
    
    private var questions = [question]()

    private let opentdbURL = "https://opentdb.com/api.php?"
    
    
    //MARK: -isOfflineMode
    // isOfflineMode() Set to true if the database should use the offline questions
    //Parameters: NONE
    //Return: Bool
    public func isOfflineMode() -> Bool{
    return offlineMode
    }
    
    
    //MARK: -setOfflineMode
    // setOfflineMode(mode: Bool) Set to true if the database should use the offline questions
    //Parameters: NONE
    //Return: Void
    public func setOfflineMode(mode: Bool) -> Void{
        offlineMode = mode
    }
    
    // isQuestionsReady() Returns true if data is ready
    //Parameters: NONE
    //Return: Bool
    public func isQuestionsReady() -> Bool {
        return self.IsDataReady
    }
    
    
    //MARK: -getQestions
    // getQuestions() returns list of questions if data is ready else returns empty list
    //Parameters: NONE
    //Return: [question]
    func getQestions() -> [question] {
        if (IsDataReady || offlineDataReady){
            return questions
        }
        else {
            return [question]()
        }
    }
    
    
    //MARK: -getUrl
    // getUrl() Returns the url for the database
    //Parameters: category (optional): string, nrOfQuestions (optional): int, diffeculty: (optional): string
    //Return: URL
    private func getUrl(category: String? = nil, nrOfQuestions: Int = 10, difficulty: String? = nil) ->  URL {
        let typeOfQuestion = "multiple"
        var jsonURLAsString = opentdbURL + "amount=" + String(nrOfQuestions) + "&type=" + typeOfQuestion
        if (category != nil) {
            jsonURLAsString = jsonURLAsString + "&category=" + category!
        }
        if (difficulty != nil){
            jsonURLAsString = jsonURLAsString + "&difficulty=" + difficulty!
        }
        //TODO Ta bort kommentar när det är klart!
        print(jsonURLAsString)
        questions = [question]()
        
        //Checking the url is ok:
        guard let url = URL(string: jsonURLAsString) else {
            print("Opentdb: No URL")
            return URL(string: "")!
        }
        return url
    }
    
    
    //MARK: -getQuestionsFromDB
    // getQuestionsFromDB(category: String? = nil, nrOfQuestions: Int = 10, difficulty: String? = nil) -> Void gets 10 new questions and puts them in the class variable questions
    //Parameters: category (optional): string, nrOfQuestions (optional): int, diffeculty: (optional): string
    //Return: VOID
    public func getQuestionsFromDB(category: String? = nil, nrOfQuestions: Int = 10, difficulty: String? = nil) -> Void {
        print("Opentdb: GetQuestions()")
        self.IsDataReady = false
        let url = self.getUrl(category: category, nrOfQuestions: nrOfQuestions, difficulty: difficulty)
        //Retrivieng data ascync:
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            //If no data recieved:
            guard let data = data else {
                print("Opentdb: No data")
                return
            }
            //Decoding JSON:
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else {
                    print("Opentdb: Något gick snett med avkodningen av json")
                    return
                }
                let results = json["results"]
                //Looping through all questions recieved:
                for object in (results as! NSArray) {
                    if let x : NSDictionary = object as? NSDictionary{
                        let category = (x["category"] as! String).stringByDecodingHTMLEntities
                        let quest = (x["question"] as! String).stringByDecodingHTMLEntities
                        let correct_answer = (x["correct_answer"] as! String).stringByDecodingHTMLEntities
                        let difficulty = (x["difficulty"] as! String).stringByDecodingHTMLEntities
                        var incorrect_answers = [String]()
                        for i in (x["incorrect_answers"] as? NSArray)!{
                            incorrect_answers.append((i as! String).stringByDecodingHTMLEntities)
                        }
                        //Adding all info in the object to the question struct
                        let structQuestion = question(difficulty: difficulty, category: category, question: quest, correct_answer: correct_answer, incorrect_answers: incorrect_answers)
                        //Append question strukt to list of questions:
                        self.questions.append(structQuestion)
                    }
                    
                }

            } catch{
                print("Opentdb: Något gick snett i datahanteringen")
                return
            }
            //DONE!
            print("Opentdb: Klar med datahanteringen")
            self.IsDataReady = true
            }.resume()
        
    }
    
    
    //MARK: -storeOffline
    // storeOffline() -> Void gets 50 new questions and puts them in offlineQuestions.txt localy on device
    //Parameters: none
    //Return: VOID
    func storeOffline() -> Void {
        print("offlinelagring")
        var offlineQuestions = [question]()
        let url = self.getUrl(nrOfQuestions: 50)
        let file = "offlineQuestions.txt" //this is the file. we will write to and read from it
        
        let text = "Questions \n" //just a text
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            //Retrivieng data ascync:
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                //If no data recieved:
                guard let data = data else {
                    print("Opentdb: No data")
                    self.setOfflineMode(mode: false)
                    return
                }
                //Decoding JSON:
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else {
                        print("Opentdb: Något gick snett med avkodningen av json")
                        return
                    }
                    let results = json["results"]
                    //Looping through all questions recieved:
                    for object in (results as! NSArray) {
                        if let x : NSDictionary = object as? NSDictionary{
                            let category = (x["category"] as! String).stringByDecodingHTMLEntities
                            let quest = (x["question"] as! String).stringByDecodingHTMLEntities
                            let correct_answer = (x["correct_answer"] as! String).stringByDecodingHTMLEntities
                            let difficulty = (x["difficulty"] as! String).stringByDecodingHTMLEntities
                            var incorrect_answers = [String]()
                            for i in (x["incorrect_answers"] as? NSArray)!{
                                incorrect_answers.append((i as! String).stringByDecodingHTMLEntities)
                            }
                            //Adding all info in the object to the question struct
                            let structQuestion = question(difficulty: difficulty, category: category, question: quest, correct_answer: correct_answer, incorrect_answers: incorrect_answers)
                            //Append question strukt to list of questions:
                            offlineQuestions.append(structQuestion)
                        }
                        
                    }
                    
                } catch{
                    print("Opentdb: Något gick snett i datahanteringen")
                    return
                }

                // Writing
                do {
                    try text.write(to: fileURL, atomically: false, encoding: .utf8) // Creates fil if not exists
                    for q in offlineQuestions {
                        var dataString =  " : question : " + String(q.question) + " : difficulty : " + q.difficulty + " : correct_answer : " + q.correct_answer + " : category : " + q.category
                        dataString = dataString + " : incorrect_answer1 : " + q.incorrect_answers[0] + " : incorrect_answer2 : " + q.incorrect_answers[1] + " : incorrect_answer3 : " + q.incorrect_answers[2] + "\n"
                        //Check if file exists then append to file
                        do {
                            let fileHandle = try FileHandle(forWritingTo: fileURL)
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(dataString.data(using: .utf8)!)
                            fileHandle.closeFile()
                        } catch {
                            print("Error writing to file \(error)")
                        }
                    }
                }
                catch {/* error handling here */
                    print("Somwthing went wrong when writing to file..")
                }
                print("Done with writing to file")
                
                }.resume()
            
        }
        
    }
    
    
    // MARK: -getOfflineQuestions
    // getOfflineQuestions() -> [question] gets all questions from offline stored data
    // Parameters: none
    // Return: [question]
    private func getOfflineQuestions() -> [question] {
        let file = "offlineQuestions.txt" //this is the file.
        var offlineQuestions = [question]()

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            var questions: String
            do {
                questions = try String(contentsOf: fileURL, encoding: .utf8) // Reading
                let questionsArray = questions.components(separatedBy: "\n") // Splitting the questions
                
                for questionItem in questionsArray {
                    let items = questionItem.components(separatedBy: " : ") // Splitting the items in every question
                    var incorrect_answers = [String]()
                    var quest = ""
                    var difficulty = ""
                    var correct_answer = ""
                    var category = ""
                    
                    for (index, item) in items.enumerated(){
                        if (item == "question"){
                            quest = (items[index + 1]).stringByDecodingHTMLEntities
                        }
                        else if (item == "difficulty"){
                            difficulty = (items[index + 1]).stringByDecodingHTMLEntities
                        }
                        else if (item == "correct_answer"){
                            correct_answer = (items[index + 1]).stringByDecodingHTMLEntities
                        }
                        else if (item == "category"){
                            category = (items[index + 1]).stringByDecodingHTMLEntities
                        }
                        else if (item == "incorrect_answer1" || item == "incorrect_answer2" || item == "incorrect_answer3"){
                            incorrect_answers.append((items[index + 1]).stringByDecodingHTMLEntities)
                        }
                    }
                    
                    if (quest != ""){
                        let structQuestion = question(difficulty: difficulty, category: category, question: quest, correct_answer: correct_answer, incorrect_answers: incorrect_answers)
                        offlineQuestions.append(structQuestion)
                    }
                    
                }
                return offlineQuestions
            }
            catch {/* error handling here */
                return [question]()
            }
        }
        return [question]()
    }
    
    
    // MARK: -tenRandomOfflineQuestions
    // tenRandomOfflineQuestions() -> Void gets 10 random questions from offline stored data and puts them in self.questions
    //Parameters: none
    //Return: Void
    public func tenRandomOfflineQuestions() -> Void {
        offlineDataReady = false //So that the data is not accessable untill data read is done!
        var offlineQuestions: [question] = getOfflineQuestions() //get all offline questions
        let totalQuestions = offlineQuestions.count
        
        var randomQuestions : [question] = []
        var randomNumbers: [Int] = []
        
        // Gets 10 random numbers
        var i = 0
        while i < 10 {
            let number = Int.random(in: 0 ..< totalQuestions)
            if !randomNumbers.contains(number){
                randomNumbers.append(number)
                i = i + 1
            }
        }
        
        // Take 10 random questions
        for number in randomNumbers{
            randomQuestions.append(offlineQuestions[number])
        }
        self.questions = randomQuestions
        offlineDataReady = true // Data is ready to use!
    }
    
    
    // MARK: -isOfflineDataReady
    // isOfflineDataReady() -> Checks if the offline data is ready for use
    // Parameters: none
    // Return: Bool
    public func isOfflineDataReady() -> Bool{
        print(offlineDataReady)
        return offlineDataReady
    }
    
    
    // MARK: -hasOfflineData
    // hasOfflineData() -> Checks if there is offline data stored on divice
    //Parameters: none
    //Return: Bool
    func hasOfflineData() -> Bool {
        let file = "offlineQuestions.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                //Try to reed from file
                _ = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                //No file stored locally
                print("No file found")
                return false
            }
            //File found!
            print("File found!")
            return true
        }
        return false
    }
    
    
    // MARK: -deleteFile
    // deleteFile() -> Deletes localy stored data
    //Parameters: none
    //Return: Void
    func deleteFile() -> Void {
        let file = "offlineQuestions.txt"
        let fileManeger = FileManager.default
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            do{
                try fileManeger.removeItem(at: fileURL) //try to delete the file
            }catch{
                //ERROR
                print("Could not remove file")
                return
            }
            //Sucess!
            print("File removed!")
        }
    }
}
