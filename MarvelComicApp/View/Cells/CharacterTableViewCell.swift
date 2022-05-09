//
//  CharacterTableViewCell.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 03/05/22.
//

import UIKit
import SDWebImage

class CharacterTableViewCell: UITableViewCell {
    static let identifier = String(describing: CharacterTableViewCell.self)
    static let nib = UINib(nibName: identifier, bundle: nil)
    
    @IBOutlet weak var labelCharacterName: UILabel!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var buttonBookmark: UIButton!
    
    var character:MarvelCharacter?
    var toggleBookmarkCallback:((MarvelCharacter?) ->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    private func setupUI(){
        selectionStyle = .none
        labelCharacterName.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        characterImageView.layer.cornerRadius = 8.0
        characterImageView.clipsToBounds = true
        characterImageView.contentMode = .scaleToFill
        characterImageView.clipsToBounds = true
        
        mainContainerView.layer.cornerRadius = 8.0
        mainContainerView.layer.borderColor = Theme.Colors.lightGray.cgColor
        mainContainerView.clipsToBounds = true
        
        mainContainerView.dropShadow()
    }

    func setup(character:MarvelCharacter?){
        self.character = character
        if let character = character {
            if character.isBookmarked{
                buttonBookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }else{
                buttonBookmark.setImage(UIImage(systemName: "bookmark"), for: .normal)
            }
            labelCharacterName.text = character.name ?? "---"
            characterImageView.setImage(urlString: character.thumbnail?.thumbanilURLString ?? "", placeholderImage: placeholderImage)
            self.hideSkeleton()
        }else{
            self.animateSkeleton()
        }
    }
    
    @IBAction func didTapBookmarkButton(_ sender: Any) {
        if let character = character {
            toggleBookmarkCallback?(character)
        }else{
            toggleBookmarkCallback?(.none)
        }
        
    }
}
