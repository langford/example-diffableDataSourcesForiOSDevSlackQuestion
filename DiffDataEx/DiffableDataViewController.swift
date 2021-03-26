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
    return title
  }
}

var cellInfo:[String:Item] = [
  "Boohosoi":Item(title: "Boohosoi"),
  "Hoiajsdfojiasd":Item(title: "Hoiajsdfojiasd"),
  "oaijdfoijsafoiasdjf":Item(title: "oaijdfoijsafoiasdjf"),
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
    snapshot.appendItems(list.map{item in item.title})
    dataSource.apply(snapshot, animatingDifferences: animate)
  }

  func simulateUpdate() {

    let newItem = Item(title:"added \(Date())")
    print("Adding \(newItem.title)")

    let incomingDataFromServerOrUiChanges = [newItem,Item(title: "Hoiajsdfojiasd")]

    cellInfo = [:]
    for item in incomingDataFromServerOrUiChanges {
      cellInfo[item.title] = item
    }
    
    self.update(with:[newItem,Item(title: "Hoiajsdfojiasd")], animate:true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.simulateUpdate()
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("cellInfo(\(cellInfo.count))")
    return cellInfo.count
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

        let item = cellInfo[itemId]!
        print("fetching \(item.title)")
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(Date()):\(item.otherData)"
        return cell
      }
    )
  }
}

