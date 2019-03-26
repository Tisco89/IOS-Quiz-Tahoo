//
//  QuizHelperViewController.swift
//  Project
//
//  Created by Oskar Arctaedius on 2018-11-27.
//  Copyright © 2018 Oscar Stenqvist. All rights reserved.
//

import UIKit

class QuizHelperViewController: UIViewController {

    @IBOutlet weak var quizHelperImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // animate owl
        let owlAskImage = imgAnimations.getOwlAnimation() // calls owlArray
       quizHelperImageView.animationImages = owlAskImage
        quizHelperImageView.animationDuration = 2.0
        quizHelperImageView.startAnimating()
    }

}
