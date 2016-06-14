//
//  ViewController.swift
//  GangTablePoC
//
//  Created by Ricki Gregersen on 13/06/16.
//  Copyright © 2016 youandthegang.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak private var tableView: GangTableView!
	private let items: [[Any]] = [[
		CellItem(text: "Row One"),
		CellItem(text: "Row Two"),
		CellItem(text: "Row Three"),
		CellItem(text: "Row Four")
		]]


	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
	}

	func setupTableView() {
		
		tableView.setupSections(sectionCount: 1)
		tableView.sections = items

		tableView.onIdentifyCell = { data in

			switch data {
			case is CellItem:
				return "TableCell"
			default:
				return nil
			}
		}

		tableView.onConfigure = { context in

			print(context.cell)
			print(context.data)
			print(context.indexPath)
		}

		tableView.onSelect = { context in

			print(context.cell)
			print(context.data)
			print(context.indexPath)
		}
	}
}


