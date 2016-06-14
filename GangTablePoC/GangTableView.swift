//
//  CustomTableView.swift
//  TableViewSwiftPoC
//
//  Created by Ricki Gregersen on 15/01/16.
//  Copyright © 2016 youandthegang.com. All rights reserved.
//

/** Example ViewController

// Make .Nib cell with same name as identifier e.g. "TitleCell.nib" must have identifier "TitleCell"

class ViewController: UIViewController {

    @IBOutlet weak var tableView: CustomTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sections = [["Title 00", "Title 01"], ["Title 10", "Title 11"]]
        tableView.customTableViewDataSource = self
        tableView.customTableViewDelegate = self
    }
}

extension ViewController: CustomTableViewDataSource {

    func cellIdentifier(forData data: AnyObject) -> String? {

        switch data {
        case is String:
            return "TitleCell"
        default:
            return ""
        }
    }
}

*/

import UIKit

// Little convience struts for making space and dividers
struct SpaceItem {}
struct DividerItem {}

public struct TableViewContext {

	let cell: UITableViewCell
	let indexPath: NSIndexPath
	let data: Any
}

public protocol Updatable {

    func update(data data: Any)
}

public protocol TableViewDelegate: class {
    
    func configure(cell cell: UITableViewCell, tableview: UITableView, indexPath: NSIndexPath, data: Any)
    func didSelect(tableView tableview: UITableView, indexPath: NSIndexPath, data: Any)
}

public protocol TableViewDataSource: class {
    
    func cellIdentifier(forData data: Any) -> String?
}

public protocol TableViewSectionHeaderDelegate: class {

    func sectionView(forSection section: Int) -> UIView?
    func height(forSection section: Int) -> CGFloat

}

public protocol TableViewScrollDelegate: class {

    func didScroll(scrollView: UIScrollView)
    func didEndScrolling(scrollView: UIScrollView)
    
}

public class GangTableView: UITableView {

	public var onConfigure: ((context: TableViewContext) -> ())?
	public var onSelect: ((context: TableViewContext) -> ())?
	public var onIdentifyCell: ((data: Any) -> String?)?

//	public var onConfigure: ((cell: UITableViewCell, indexPath: NSIndexPath, data: Any) -> ())?
//	public var onSelect: ((cell: UITableViewCell, indexPath: NSIndexPath, data: Any) -> ())?


//	public var identifier: ((cell: UITableViewCell, indexPath: NSIndexPath, data: Any) -> ())?

    public var sections = [[Any]]()
    public weak var tableViewDelegate: TableViewDelegate?
    public weak var tableViewDataSource: TableViewDataSource?
    public weak var tableViewScrollDelegate: TableViewScrollDelegate?
    public weak var tableViewSectionHeaderDelegate: TableViewSectionHeaderDelegate?

    private var registeredIdentifiers = Set<String>()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
        dataSource = self

        self.rowHeight = UITableViewAutomaticDimension
//        self.estimatedRowHeight = 50
    }

    func data(atIndexPath indexPath: NSIndexPath) -> Any {
        return sections[indexPath.section][indexPath.row]
    }

    func setupSections(sectionCount count: Int) {

        sections = [[Any]]()

        for _ in 0..<count {
            sections.append([Any]())
        }
    }

    func reload(section section: Int, data: [Any], animation: UITableViewRowAnimation) {

        sections[section] = data
        reloadSections(NSIndexSet(index: section), withRowAnimation: animation)
    }

    func insertData(data: [Any], atIndex: Int, inSection: Int, animation: UITableViewRowAnimation?) {

        guard inSection < sections.count else { return }

        sections[inSection].insertContentsOf(data, at: atIndex)

        var indexPaths: [NSIndexPath] = []
        var idx = atIndex

        for _ in data {

            indexPaths.append(NSIndexPath(forRow: idx, inSection: inSection))
            idx += 1
        }

        let anim = animation ?? .None

        insertRowsAtIndexPaths(indexPaths, withRowAnimation: anim)
    }
}

extension GangTableView: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = sections[indexPath.section][indexPath.row]
		let cell = tableView.cellForRowAtIndexPath(indexPath)

        tableViewDelegate?.didSelect(tableView: self, indexPath: indexPath, data: data)
		onSelect?(context: TableViewContext(cell: cell!, indexPath: indexPath, data: data))
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        tableViewScrollDelegate?.didScroll(self)
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        tableViewScrollDelegate?.didEndScrolling(self)
    }
}

extension GangTableView: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = sections[indexPath.section][indexPath.row]

		if let identifier = onIdentify?(data: data) {
//        if let identifier = tableViewDataSource?.cellIdentifier(forData: data) {

            if registeredIdentifiers.contains(identifier) == false {
                
                if let _ = NSBundle.mainBundle().pathForResource(identifier, ofType: "nib") {
                    
                    let nib = UINib(nibName: identifier, bundle: nil)
                    registerNib(nib, forCellReuseIdentifier: identifier)
                    registeredIdentifiers.insert(identifier)

                } else {
                    
                    return UITableViewCell()
                }
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            
            if let cell = cell as? Updatable {
                cell.update(data: data)
            }

            tableViewDelegate?.configure(cell: cell, tableview: tableView, indexPath: indexPath, data: data)
			onConfigure?(context: TableViewContext(cell: cell, indexPath: indexPath, data: data))
            return cell
        }
        
        return UITableViewCell()
    }

    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewSectionHeaderDelegate?.sectionView(forSection: section)
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewSectionHeaderDelegate?.height(forSection: section) ?? UITableViewAutomaticDimension
    }
}
