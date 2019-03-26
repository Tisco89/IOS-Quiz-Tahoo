//
//  QuestionsViewController.swift
//  Project
//
//  Created by Tompa on 2018-11-06.
//  Copyright © 2018 Oscar Stenqvist. All rights reserved.
//

import UIKit
import AVFoundation


class QuestionsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var speechBubbleImage: UIImageView!
    @IBOutlet weak var owlAsker: UIImageView!
    
    @IBOutlet weak var answer1Btn: UIButton!
    @IBOutlet weak var answer2Btn: UIButton!
    @IBOutlet weak var answer3Btn: UIButton!
    @IBOutlet weak var answer4Btn: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var answerLabel1: UILabel!
    @IBOutlet weak var answerLabel2: UILabel!
    @IBOutlet weak var answerLabel3: UILabel!
    @IBOutlet weak var answerLabel4: UILabel!
    
    // MARK: - Variables
    
    var correctAnswer: AVAudioPlayer?
    var questionRound = 0
    var scoreCount = 0
    var timer = Timer()
    var seconds = 10
    var tapGesture = UITapGestureRecognizer()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSound()
        // navigation bar
        navigationBarItems()
        
        // timer
        timerLabel.text = ("Time left: \(seconds)")
        
        // speech-bubble
        speechBubbleImage.image = UIImage(named:"speech")
        
        // animate owl
        let owlAskImage = imgAnimations.getOwlAnimation() // calls owlArray
        owlAsker.animationImages = owlAskImage
        owlAsker.animationDuration = 2.0
        owlAsker.startAnimating()
        
        
        // start round
        putQuestions()
        setButtonSettings()
        timerCountdown()
    }
    
    // MARK: - viewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Tap Gesture
    
    func addTapGesture() {
        speechBubbleImage.isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapQuestionLabel(_:)))
        tapGesture.numberOfTapsRequired = 1
        speechBubbleImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapQuestionLabel(_ sender: UITapGestureRecognizer){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.questionRound > 9 {
                self.performSegue(withIdentifier: "playAgainSegue", sender: self)
            }
            else {
                self.flip()
                self.putQuestions()
                self.setButtonSettings()
                self.enableButtons()
                self.timerCountdown()
                self.speechBubbleImage.isUserInteractionEnabled = false
                self.timerLabel.doGlowAnimation(withColor: UIColor.clear, withEffect: .small)
            }
        }
    }
    // MARK: - Put question and answers
    
    //Updates the questionlabel and answerbuttons with the question and answers
    private func putQuestions() -> Void {
        let listOfQuestions = db.getQestions()
        if listOfQuestions.count > 0 {
            let q1 = listOfQuestions[questionRound]
            questionLabel.text = q1.question
            var ansArr = [q1.correct_answer, q1.incorrect_answers[0], q1.incorrect_answers[1], q1.incorrect_answers[2]]
            ansArr.shuffle()
            answerLabel1.text = ansArr[0]
            answerLabel2.text = ansArr[1]
            answerLabel3.text = ansArr[2]
            answerLabel4.text = ansArr[3]
        }
    }
    
    // MARK: - Button and label settings
    
    private func setButtonSettings() -> Void {
        // Answerbutton/answerlabel apperance settings
        let listOfButtons = [answer1Btn, answer2Btn, answer3Btn, answer4Btn]
        let listOfLabels = [answerLabel1, answerLabel2, answerLabel3, answerLabel4]
        for labl in listOfLabels{
            labl?.backgroundColor = UIColor.white
            labl?.layer.cornerRadius = (labl?.frame.width)! * 0.1
            labl?.minimumScaleFactor = 0.5
            labl?.adjustsFontSizeToFitWidth = true
        }
        for btn in listOfButtons {
            btn?.backgroundColor = UIColor.clear
            btn?.layer.cornerRadius = (btn?.frame.width)! * 0.1
            btn?.isExclusiveTouch = true //only one button should be pressed!
        }
    }
    
    func disableButtons() {
        self.answer1Btn.isEnabled = false
        self.answer2Btn.isEnabled = false
        self.answer3Btn.isEnabled = false
        self.answer4Btn.isEnabled = false
    }
    
    func enableButtons() {
        self.answer1Btn.isEnabled = true
        self.answer2Btn.isEnabled = true
        self.answer3Btn.isEnabled = true
        self.answer4Btn.isEnabled = true
    }
    
    // MARK: - Update buttons
    
    //Highlights the correct answer in green, no parameters no return
    func highlightCorrectAnswer() -> Void {
        let listOfLabels = [answerLabel1, answerLabel2, answerLabel3, answerLabel4]
        for labl in listOfLabels {
            if(isAnswerCorrect(answer: labl!.text!))
            {
                labl!.backgroundColor = UIColor.green
                disableButtons()
                timer.invalidate()
                addTapGesture()
            }
        }
    }
    
    @IBAction func answer1Btn(_ sender: Any) {
        if(isAnswerCorrect(answer: answerLabel1.text!))
        {
            answerLabel1.backgroundColor = UIColor.green
            correctAnswer?.play()
        }
        else {
            answerLabel1.backgroundColor = UIColor.red
            answerLabel1.shakeByX()
            UIDevice.vibrate()
        }
        addTapGesture()
        highlightCorrectAnswer()
        updateScore(answer: answerLabel1.text!)
    }
    
    @IBAction func answer2Btn(_ sender: Any) {
        if(isAnswerCorrect(answer: answerLabel2.text!))
        {
            answerLabel2.backgroundColor = UIColor.green
            correctAnswer?.play()
        }
        else {
            answerLabel2.backgroundColor = UIColor.red
            answerLabel2.shakeByX()
            UIDevice.vibrate()
        }
        addTapGesture()
        highlightCorrectAnswer()
        updateScore(answer: answerLabel2.text!)
    }
    
    @IBAction func answer3Btn(_ sender: Any) {
        if(isAnswerCorrect(answer: answerLabel3.text!))
        {
            answerLabel3.backgroundColor = UIColor.green
            correctAnswer?.play()
        }
        else {
            answerLabel3.backgroundColor = UIColor.red
            answerLabel3.shakeByX()
            UIDevice.vibrate()
        }
        addTapGesture()
        highlightCorrectAnswer()
        updateScore(answer: answerLabel3.text!)
    }
    
    @IBAction func answer4Btn(_ sender: Any) {
        if(isAnswerCorrect(answer: answerLabel4.text!))
        {
            answerLabel4.backgroundColor = UIColor.green
            correctAnswer?.play()
        }
        else {
            answerLabel4.backgroundColor = UIColor.red
            answerLabel4.shakeByX()
            UIDevice.vibrate()
        }
        addTapGesture()
        highlightCorrectAnswer()
        updateScore(answer: answerLabel4.text!)
    }
    
    // MARK: - Timer
    
    func timerCountdown() {
        seconds = 10
        timerLabel.text = "Time Left: \(String(seconds))"
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
    }
    
    @objc func counter() {
        seconds -= 1
        timerLabel.text = "Time Left: \(String(seconds))"
        if seconds < 5 {
            timerLabel.doGlowAnimation(withColor: UIColor.red, withEffect: .big)
        }
        
        if seconds <= 0 {
            timerLabel.text = "TIMES UP!"
            timer.invalidate()
            UIDevice.vibrate()
            disableButtons()
            highlightCorrectAnswer()
            questionRound += 1
            scoreLabel.text = "\(scoreCount) / \(questionRound)"
        }
    }
    
    // MARK: - Navigation bar
    
    private func navigationBarItems() {
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let titleImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        titleImageView.contentMode = .scaleAspectFit
        
        let navImage = UIImage(named: "owl1")
        titleImageView.image = navImage
        
        navigationItem.titleView = titleImageView
    }

    // MARK: - Animate question
    
    // flips speechbubble and hides question for 1 second
    @objc func flip() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: speechBubbleImage, duration: 1.0, options: transitionOptions, animations: {
            self.questionLabel.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.questionLabel.isHidden = false
            }
        })
    }
    
    // MARK: - Control of answer
    
    //Checks if the answer sent as parameter is correct, returns true if correct
    private func isAnswerCorrect(answer: String) -> Bool {
        let listOfQuestions = db.getQestions()
        let q1 = listOfQuestions[questionRound]
        if q1.correct_answer == answer { return true }
        return false
    }
    
    // MARK: - Update the score
    
    func updateScore(answer: String) {
        let listOfQuestions = db.getQestions()
        let q1 = listOfQuestions[questionRound]
        if q1.correct_answer == answer {
            scoreCount += 1
        }
        questionRound += 1
        scoreLabel.text = "\(scoreCount) / \(questionRound)"
        UserDefaults.standard.set(scoreCount, forKey: "userScore")
    }
    
    // MARK: - Load sound
    
    // Load sound on buttonclick function in viewDidLoad
    func loadSound(){
        do{
            if let fileURL = Bundle.main.path(forResource: "correctAnswer", ofType: "wav"){
                correctAnswer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            }else{
                print("no file with that name exists")
            }
        }catch let error{
            print("cant play the audio file, failed with error \(error.localizedDescription)")
        }
    }
    
}
