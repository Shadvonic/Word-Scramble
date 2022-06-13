//
//  ViewController.swift
//  Word_Scramble
//
//  Created by Marc Moxey on 5/22/22.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(startGame))
        //found file in bundle
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //try to load the file
            if let startWords = try? String(contentsOf: startWordURL) {
                //assign words from file into allWords array separated by line break
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
                //if couldn't load file used default word
                allWords = ["Silkworm"]
        }
        startGame()
            
    }
    
    @objc func startGame() {
        //set title to be random word
        title = allWords.randomElement()
        //remove all words from array when new word comes up
        usedWords.removeAll(keepingCapacity: true)
        //reload rows and section from starch
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    
    //all the words the user found
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        //add textField to alert controller
        ac.addTextField()
        
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            
            //input into the closure
            //used weak to not capture strongly
            //safely checks if self there before running the closure  and ac is still there before running the submit
            [weak self, weak ac] _ in //things you want to do after the closure is run
            //read the textField out
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        
        //add action to alert controller
        ac.addAction(submitAction)
        //present it
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        //make answer to lowercase to avoid user mistakes
        let lowerAnswer = answer.lowercased()
        //let errorTitle: String
        //let errorMsg: String
        
        //check if letter are given can make the word
        if isPossible(word: lowerAnswer) {
            //check if the word has not been used before
            if  isOriginal(word: lowerAnswer) {
                //check if the actually word
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    let indexPath = IndexPath(row:  0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage("You can't just make them up, you know!", withTitle:  "Word not recognized")
                }
            } else {
                showErrorMessage("Be more original!", withTitle: "Word already used")
            }
        } else {
            guard let title = title else { return }
            showErrorMessage("You can't spell that word from \(title.lowercased()).", withTitle: "Word not possible")
        
        }
    }
    
    func isPossible(word: String) -> Bool {
        
        guard var tempWord = title?.lowercased() else { return false }
        
        //loop over all the letters in the word
     
            for letter in word {
                //find the first time the letter appears in tempWord
                if let position = tempWord.firstIndex(of: letter) {
                    //remove letter from tempWord if can find that letter
                    tempWord.remove(at: position)
                } else {
                    //if cant return false and stop checking
                    
                    return false
                }
            }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        guard word != title else { return false}
        //does not contain word in array
        return !usedWords.contains(word)
        
    }
    
    func isReal(word: String) -> Bool {
        
        guard word.count >= 3 else { return false}
        
        
        let checker = UITextChecker()
        //range to scan to full length of the word
        let range = NSRange(location: 0, length: word.utf16.count)
        //string to scan
        //how much of the word to scan(full word)
        //the language dictionary you want to check
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        //return word that misspelled
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(_ errorMsg: String, withTitle errorTitle:String) {
        let ac = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
}


