//
//  TableCell.swift
//  GangTablePoC
//
//  Created by Ricki Gregersen on 13/06/16.
//  Copyright © 2016 youandthegang.com. All rights reserved.
//

import UIKit

struct CellItem {

	let text: String
}

class TableCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension TableCell: Updatable {

	func update(data data: Any) {
		if let item = data as? CellItem {
			titleLabel.text = item.text
		}
	}

}
