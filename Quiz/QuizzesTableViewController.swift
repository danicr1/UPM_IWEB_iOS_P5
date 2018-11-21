//
//  QuizzesTableViewController.swift
//  Quiz
//
//  Created by Daniel  on 18/11/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

struct Item: Codable {
    let quizzes: [Quiz]
    let pageno: Int
    let nextUrl: String
}

struct Quiz: Codable {
    let id: Int
    let question: String
    let author: Author?
    let attachment: Attachment
    let favourite: Bool
    let tips: [String]
}

struct Author: Codable {
    let id: Int
    let isAdmin: Bool?
    let username: String
}

struct Attachment: Codable {
    let filename: String
    let mime: String
    let url: String
}

class QuizzesTableViewController: UITableViewController, QuizzesTableViewCellDelegate {
   
    let URLBASE = "https://quiz2019.herokuapp.com/api"
    let MY_TOKEN = "08377e567fee7be1ec10"
    
    var items = [Item]()
    var quizzes = [Quiz]()
    var imagesCache = [String:UIImage]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "\(URLBASE)/quizzes?token=\(MY_TOKEN)"
        download(urlStr: urlString)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return quizzes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quiz cell", for: indexPath) as! QuizzesTableViewCell
        
        cell.delegate = self
        
        let quiz = quizzes[indexPath.row]
        
        cell.questionLabel.text = quiz.question
        if let author = quiz.author?.username {
            cell.authorLabel.text = author
        } else {
            cell.authorLabel.text = "Sin autor"
        }
        
        if let img = imagesCache[quiz.attachment.url] {
            cell.pictureImageView.image = img
        } else {
            cell.pictureImageView.image = UIImage(named: "none")
            downloadPicture(imgUrl: quiz.attachment.url, indexPath: indexPath)
        }
        
        if quiz.favourite {
            cell.favButton.setImage(UIImage(named: "fav"), for: .normal)
        } else {
            cell.favButton.setImage(UIImage(named: "nofav"), for: .normal)
        }
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func download(urlStr: String) {
        if let url = URL(string: urlStr){
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                if let data = try? Data(contentsOf: url){
                    let decoder = JSONDecoder()
                    
                    if let item = try? decoder.decode(Item.self, from: data){
                        DispatchQueue.main.async {
                            self.items.append(item)
                        }
                        if !item.nextUrl.isEmpty {
                            self.downloadNextItems(itemUrl: item.nextUrl)
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            for itm in self.items{
                                for qz in itm.quizzes{
                                    self.quizzes.append(qz)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                    }
                }
            }
        } else {
            print("Error con la url", urlStr)
        }
    }
    
    func downloadNextItems(itemUrl: String) {
        if let url = URL(string: itemUrl) {
            if let data = try? Data(contentsOf: url) {
                let decoder = JSONDecoder()
                
                if let item = try? decoder.decode(Item.self, from: data){
                    DispatchQueue.main.async {
                        self.items.append(item)
                    }
                    if !item.nextUrl.isEmpty {
                        self.downloadNextItems(itemUrl: item.nextUrl)
                    }
                }
            }
        }
    }
    
    func downloadPicture(imgUrl: String, indexPath: IndexPath) {
        //guard let escapedUrl = imgUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {print("fallo")}
        DispatchQueue.global().async {
            if let url = URL(string: imgUrl) {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                if let data = try? Data.init(contentsOf: url) {
                    if let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imagesCache[imgUrl] = img
                            self.tableView.reloadRows(at: [indexPath], with: .fade)
                        }
                    }
                }
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
    
    func setFavourite(cell: QuizzesTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            // No debería fallar nunca, el usuario va a hacer tap en una cell que no esta en la pantalla?
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let quiz = quizzes[indexPath.row]
        let isFav = quiz.favourite
        let quizId = quiz.id
        let strUrl = "\(URLBASE)/users/tokenOwner/favourites/\(quizId)?token=\(MY_TOKEN)"
        if let url = URL(string: strUrl) {
            // Creamos a request
            var request = URLRequest(url: url)
            
            // Según la API debemos usar distintos métodos dependiendo de si queremos añadir/quitar de favoritos
            if isFav {
                request.httpMethod = "DELETE" // Lo quitamos de favoritos
            } else {
                request.httpMethod = "PUT" // Lo añadimos a favoritos
            }
            
            // Creamos la tarea para hacer la petición
            let task = session.dataTask(with: request) { (data: Data?, res: URLResponse?, error: Error?) in
                
                defer{ //Siempre, al salir de este ámnito de ejecución
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                
                // Si se produce un error lo imprimimos y finalizamos la tarea
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                // Comprobamos que el código de la respuesta es 200 como indica la API
                let code = (res as! HTTPURLResponse).statusCode
                if code != 200 {
                    print("No se ha podido modificar el favorito")
                    print(HTTPURLResponse.localizedString(forStatusCode: code))
                    return
                }
                
                // Cambiamos la imagen del boton (también se podría descargar el quiz actualizado)
                DispatchQueue.main.async {
                    if isFav {
                        cell.favButton.setImage(UIImage(named: "nofav"), for: .normal)
                    } else {
                        cell.favButton.setImage(UIImage(named: "fav"), for: .normal)
                    }
                }
                print("Favorito modificado correctamente!")
            }
            
            task.resume() // Reanudamos la tarea para que comience
        }

    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show quiz" {
            let qvc = segue.destination as! QuizViewController
            if let ip = tableView.indexPathForSelectedRow {
                let selectedQuiz = quizzes[ip.row]
                qvc.quiz = selectedQuiz
                qvc.img = imagesCache[selectedQuiz.attachment.url]
            }
        }
    }
    

}
