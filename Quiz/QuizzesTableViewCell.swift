//
//  QuizzesTableViewCell.swift
//  Quiz
//
//  Created by Daniel  on 18/11/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

// Clase que implementará el delegado de la celda para atender la pulsación del botón
protocol QuizzesTableViewCellDelegate: class {
    func setFavourite(cell: QuizzesTableViewCell)
}

class QuizzesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    
    // Variable para guardar el delegado de la celda
    var delegate: QuizzesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Al final limpiamos el delegado para la reutilización de la celda
        self.delegate = nil
    }
    
    // Función que atiende la pulsación del botón y llama a la función
    // del delegado que se encargará de (des)marcar el favorito
    @IBAction func favButtonTapped(_ sender: UIButton) {
        self.delegate?.setFavourite(cell: self)
    }
    
}
