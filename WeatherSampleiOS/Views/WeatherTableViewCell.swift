//
//  WeatherTableViewCell.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topDetailLabel: UILabel!
    @IBOutlet weak var bottomDetailLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
