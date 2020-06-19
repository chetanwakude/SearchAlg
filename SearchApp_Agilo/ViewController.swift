//
//  ViewController.swift
//  SearchApp_Agilo
//
//  Created by Chetan on 19/06/20.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit
import InstantSearchClient
import InstantSearch


class ViewController: UIViewController {
    
    let searcher: SingleIndexSearcher = .init(appID: "561IJ2TRLC",
                                              apiKey: "0f14c108cc9cf0a883d0be15ff0b1000",
                                              indexName: "app_Find")
    
    let queryInputInteractor: QueryInputInteractor = .init()
    let searchBarController: SearchBarController = .init(searchBar: UISearchBar())
    
    let statsInteractor: StatsInteractor = .init()
    let statsController: LabelStatsController = .init(label: UILabel())
    
    let hitsInteractor: HitsInteractor<JSON> = .init()
    let hitsTableController: HitsTableController<HitsInteractor<JSON>> = .init(tableView: UITableView())
    

    
    let categoryInteractor: FacetListInteractor = .init(selectionMode: .single)
    let categoryTableViewController: UITableViewController = .init()
    lazy var categoryListController: FacetListTableController = {
      return .init(tableView: categoryTableViewController.tableView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        setup()
        configureUI()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func setData() {
        let client = Client(appID: "561IJ2TRLC", apiKey: "0f14c108cc9cf0a883d0be15ff0b1000")
        let index = client.index(withName: "app_Find")

        // Load content file
        let jsonURL = Bundle.main.url(forResource: "Data", withExtension: "json")
        let jsonData = try! Data(contentsOf: jsonURL!)
        let dict = try! JSONSerialization.jsonObject(with: jsonData)

        // Load all objects in the JSON file into an index named "contacts".
        
        index.addObjects(dict as! [[String : Any]])
        
        // search by firstname
        index.search(Query(query: "jimmie"), completionHandler: { (content, error) -> Void in
            if error == nil {
                print("Result: \(content)")
            }
        })
    }
      
        
      func setup() {
      
        queryInputInteractor.connectSearcher(searcher)
        queryInputInteractor.connectController(searchBarController)
        
        statsInteractor.connectSearcher(searcher)
        statsInteractor.connectController(statsController)
        
        hitsInteractor.connectSearcher(searcher)
        hitsInteractor.connectController(hitsTableController)
       

        hitsTableController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        hitsTableController.dataSource = .init(cellConfigurator: { tableView, hit, indexPath in
          let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
          cell.textLabel?.text = [String: Any](hit)?["firstname"] as? String
          return cell
        })
        
        searcher.search()
      }
      
      func configureUI() {
      
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let searchBar = searchBarController.searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        searchBar.searchBarStyle = .minimal
        
       
        
        let searchBarFilterButtonStackView = UIStackView()
        searchBarFilterButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        searchBarFilterButtonStackView.spacing = 4
        searchBarFilterButtonStackView.axis = .horizontal
        searchBarFilterButtonStackView.addArrangedSubview(searchBar)
        
        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: 4).isActive = true
        searchBarFilterButtonStackView.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(searchBarFilterButtonStackView)
        
        let statsLabel = statsController.label
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        stackView.addArrangedSubview(statsLabel)

        stackView.addArrangedSubview(hitsTableController.tableView)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
          stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
          stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
          stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
          stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
          ])
      }
}


