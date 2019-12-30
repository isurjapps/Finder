//
//  RestaurantTableViewCell.swift
//  Finder
//
//  Created by Prashant Singh on 8/12/19.
//  Copyright © 2019 Prashant Singh. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
        
    @IBOutlet weak var cellScrollView: UIScrollView!
    @IBOutlet weak var cellRestName: UILabel!
    @IBOutlet weak var cellRestRating: UILabel!
    @IBOutlet weak var cellRatingStar1: UIImageView!
    @IBOutlet weak var cellRatingStar2: UIImageView!
    @IBOutlet weak var cellRatingStar3: UIImageView!
    @IBOutlet weak var cellRatingStar4: UIImageView!
    @IBOutlet weak var cellRatingStar5: UIImageView!
    @IBOutlet weak var cellTotalRating: UILabel!
    @IBOutlet weak var cellOpenHours: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
