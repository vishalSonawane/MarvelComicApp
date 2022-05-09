//
//  CharacterDetailsViewController.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 08/05/22.
//

import UIKit

class CharacterDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    static let identifier = String(describing: CharacterDetailsViewController.self)
    var character:MarvelCharacter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        self.title = character?.name
    }
}
extension CharacterDetailsViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.textLabel?.text = character?.comics?.items[indexPath.row].name
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (character?.comics?.items.count ?? 0 > 5) ? 5 : (character?.comics?.items.count ?? 0)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200.0))
        headerView.contentMode = .scaleToFill
        headerView.setImage(urlString: character?.thumbnail?.thumbanilURLString ?? "", placeholderImage: placeholderImage)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
}
