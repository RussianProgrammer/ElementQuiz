//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Владислав Тарасов on 28.04.2023.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    enum Mode {
        case flashCard, quiz
    }
    var mode: Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            
            updateUI()
        }
    }
    
    enum State {
        case question, answer, score
    }
    var state: State = .question
    
    enum ShuffleMode {
        case shuffled, notShuffled
    }
    var shuffleMode: ShuffleMode = .shuffled

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shuffleSwitch: UISwitch!
    @IBOutlet weak var shuffleLabel: UILabel!
    
    @IBAction func showAnswer(_ sender: UIButton) {
        state = .answer
        updateUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        
        updateUI()
    }
    
    @IBAction func switchModes(_ sender: UISegmentedControl) {
        if modeSelector.selectedSegmentIndex == 0 {
                mode = .flashCard
            } else {
                mode = .quiz
            }
    }
    
    @IBAction func switchShuffle(_ sender: UISwitch) {
        if sender.isOn {
            shuffleMode = .shuffled
        } else {
            shuffleMode = .notShuffled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mode = .flashCard
    }
    
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    var currentElementIndex = 0
    
    // Updates the app's UI in flash card mode.
    func updateFlashCardUI(elementName: String) {
        textField.isHidden = true
        shuffleLabel.isHidden = false
        shuffleSwitch.isHidden = false
        textField.resignFirstResponder()
        
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        
        modeSelector.selectedSegmentIndex = 0
        
        // Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
    }
    
    // Updates the app's UI in quiz mode.
    func updateQuizUI(elementName: String) {
        // Text field and keyboard
        textField.isHidden = false
        shuffleSwitch.isHidden = true
        shuffleLabel.isHidden = true
        
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }

        // Answer label
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect answer: \(elementName)"
            }
        case .score:
            answerLabel.text = ""
        }
        
        if state == .score {
            displayScoreAlert()
        }
        
        modeSelector.selectedSegmentIndex = 1
        
        // Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
    }
    
    // Updates the app's UI based on its mode and state.
    func updateUI() {
        // Shared code: updating the image
        let elementName =
           elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    // Quiz-specific state
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    // Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Get the text from the text field
        let textFieldContents = textField.text!
        
        // Determine whether the user answered correctly and update appropriate quiz state
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        // The app should now display the answer to the user
        state = .answer
        
        updateUI()
        
        return true
    }
    
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count)", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
    
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        switch shuffleMode {
        case .shuffled:
            elementList = fixedElementList.shuffled()
        case .notShuffled:
            elementList = fixedElementList
        }
    }
}
