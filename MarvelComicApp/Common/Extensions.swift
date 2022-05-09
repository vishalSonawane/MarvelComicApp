//
//  Extensions.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 03/05/22.
//

import Foundation
import UIKit
import SkeletonView
import SDWebImage
import RealmSwift

extension UIColor{
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
extension UIImageView{
    func setImage(urlString: String,placeholderImage:UIImage){
        
        guard let url = URL(string: urlString) else {
            self.image = placeholderImage
            return
        }
        let options:SDWebImageOptions = [.continueInBackground]
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        self.sd_imageTransition = .fade
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: options)
    }
}
extension UIView {
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
extension UINavigationController{
    func setupThemeProperties(){
        if #available(iOS 13.0, *){
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [.foregroundColor: Theme.Colors.primary]
            appearance.largeTitleTextAttributes = [.foregroundColor: Theme.Colors.primary]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }else{
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.Colors.primary]
        }
    }
}
extension UIView{
    func animateSkeleton(){
        let gradient = SkeletonGradient(baseColor: UIColor.lightGray)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        self.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
}
extension Results {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
}
