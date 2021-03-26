//
//  DiffableDataViewController.swift
//  DiffDataEx
//
//  Created by Michael Langford on 3/26/21.
//

import UIKit

import Foundation

@objc class Item: NSObject {
  var title: String
  var otherData: String = "fooasdoigjaoijwef\(UUID())"
  init(title: String) {
    self.title = title
  }
}

extension Item{
  var itemDiffableId:String{
    return "\(title)+anotherMemberPerhaps"
  }
}

let exampleItem = Item(title: "Hoiajsdfojiasd")
var cellInfo:[String:Item] = [
  exampleItem.itemDiffableId:exampleItem
]

class DiffableDataViewController: UITableViewController {
  private let cellReuseIdentifier = "SubtitleCell"
  private lazy var dataSource = makeDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    tableView.dataSource = dataSource
    simulateUpdate()
  }

  func update(with list: [Item], animate: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
    snapshot.appendSections([0])
    snapshot.appendItems(list.map{item in item.itemDiffableId})
    dataSource.apply(snapshot, animatingDifferences: animate)
  }

  func simulateUpdate() {

    let newItem = Item(title:"added \(Date())")
    print("Adding \(newItem.title)")

    let incomingDataFromServerOrUiChanges = [
      newItem,
      Item(title: "Hoiajsdfojiasd"),
      Item(title: "Other Item")
    ]

    //updates the external data structure, you could just use
        //an array too, depending on the type/amount of data
        //downloaded vs displayed sparseness
    cellInfo = [:]
    for item in incomingDataFromServerOrUiChanges {
      cellInfo[item.itemDiffableId] = item
    }
    
    self.update(with:incomingDataFromServerOrUiChanges, animate:true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.simulateUpdate()
    }
  }
}

private extension DiffableDataViewController {
  func makeDataSource() -> UITableViewDiffableDataSource<Int, String> {

    return UITableViewDiffableDataSource<Int, String>(
      tableView: tableView,
      cellProvider: {  tableView, indexPath, itemId in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: self.cellReuseIdentifier,
          for: indexPath
        )

        //Notice the use of an identifer to index into an external data structure
        //  This is the key way to avoid issues with
        //  "my item is already hashable, but not the right way".
        let item = cellInfo[itemId]!
        print("fetching \(item.title)")
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(Date()):\(item.otherData)"
        return cell
      }
    )
  }
}

