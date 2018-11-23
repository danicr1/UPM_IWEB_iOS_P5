//
//  PistasTableViewController.swift
//  Quiz
//
//  Created by Daniel  on 19/11/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

class PistasTableViewController: UITableViewController {
    
    var pistas = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pistas"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pistas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pista cell", for: indexPath)
        
        let pista = pistas[indexPath.row]
        
        cell.textLabel?.text = pista

        return cell
    }
    
}
