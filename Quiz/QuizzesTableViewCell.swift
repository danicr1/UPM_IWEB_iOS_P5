//
//  QuizzesTableViewCell.swift
//  Quiz
//
//  Created by Daniel  on 18/11/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

protocol QuizzesTableViewCellDelegate: class {
    func setFavourite(cell: QuizzesTableViewCell)
}

class QuizzesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    
    var delegate: QuizzesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }

    @IBAction func favButtonTapped(_ sender: UIButton) {
        self.delegate?.setFavourite(cell: self)
    }
    
}
