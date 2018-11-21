//
//  QuizViewController.swift
//  Quiz
//
//  Created by Daniel  on 19/11/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

struct CheckItem: Codable {
    let quizId: Int
    let answer: String
    let result: Bool
}

class QuizViewController: UIViewController, UITextFieldDelegate {
    
    var quiz : Quiz?
    var img : UIImage?

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var pictureImgView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerTextField.delegate = self
        answerTextField.placeholder = "Respuesta"
        
        title = "Responda:"
        questionLabel.text = quiz?.question
        pictureImgView.image = img
        resultLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Si devuelve true, se realizan las acciones definidas al pulsar intro en el teclado
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //Esconde el teclado
        return true
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        let URLBASE = "https://quiz2019.herokuapp.com/api"
        let MY_TOKEN = "08377e567fee7be1ec10"
        let userAnswer = answerTextField.text
        guard let queryAnswer = userAnswer?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error escapando la respuesta")
            return
        }
        let ansUrl = "\(URLBASE)/quizzes/\(quiz!.id)/check?answer=\(queryAnswer)&token=\(MY_TOKEN)"
        
        DispatchQueue.global().async {
            if let url = URL(string: ansUrl) {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                if let data = try? Data(contentsOf: url){
                    let decoder = JSONDecoder()
                    
                    if let checkItem = try? decoder.decode(CheckItem.self, from: data){
                        DispatchQueue.main.async {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            if checkItem.result {
                                self.resultLabel.textColor = .green
                                self.resultLabel.text = "Correcto"
                            } else{
                                self.resultLabel.textColor = .red
                                self.resultLabel.text = "Incorrecto"
                            }
                        }
                    }
                }
            } else {
                print("Error al construir la URL")
            }
        }
        
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show pistas" {
            let pvc = segue.destination as! PistasTableViewController
            pvc.pistas = quiz?.tips ?? []
        }
        
    }
    

}
