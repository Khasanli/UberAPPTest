//
//  OnboardingViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 27.06.21.
//

import UIKit

class OnboardingViewController: UIViewController{
//MARK:-OBJECTS
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    let pageController : UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.pageIndicatorTintColor = .gray
        control.currentPageIndicatorTintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        control.isUserInteractionEnabled = false
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let nextButton : UIButton = {
        let button  = UIButton()
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
//MARK:-LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor  = .white
        view.addSubview(collectionView)
        view.addSubview(nextButton)
        view.addSubview(pageController)
        collectionView.delegate = self
        collectionView.dataSource = self
        setSubviews()
    }
//MARK:-SET LAYOUT
    private func setSubviews(){
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
                
        nextButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: view.frame.size.height/16).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        nextButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        nextButton.layer.cornerRadius = view.frame.size.width/14

        pageController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageController.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: 10).isActive = true
        pageController.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        pageController.heightAnchor.constraint(equalToConstant: view.frame.size.height/16).isActive = true
    }
//MARK:-FUNCTION
    @objc private func nextButtonTapped(){
        if pageController.currentPage == 2 {
            let vc = EntryViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            pageController.currentPage += 1
            let indexPath = IndexPath(item: pageController.currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
}

extension OnboardingViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        if indexPath.row == 0 {
            cell.backgroundColor = .white
            cell.imageView.image = UIImage(named: "onboardingImage1")
            cell.titleLabel.text = "Find Taxi You Want"
            cell.detailsLabel.text = "Discover the best taxe from over 1,000 taxi drivers and fast delivery to your doorstep"
        } else if indexPath.row == 1 {
            cell.backgroundColor = .white
            cell.imageView.image = UIImage(named: "onboardingImage2")
            cell.titleLabel.text = "Fast Delivery"
            cell.detailsLabel.text = "Fast delivery to your home, office wherever you are"
        } else {
            cell.backgroundColor = .white
            cell.imageView.image = UIImage(named: "onboardingImage3")
            cell.titleLabel.text = "Live Tracking"
            cell.detailsLabel.text = "Real time tracking of your driver on the app once you placed the order"
        }
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width  = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / width)
        pageController.currentPage = currentPage

    }
}
class CustomCell: UICollectionViewCell {
    var imageView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var detailsLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(detailsLabel)
        setupSubviews()
    }
    private func setupSubviews(){
        imageView.bottomAnchor.constraint(equalTo: superview?.centerYAnchor ?? self.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: superview?.centerXAnchor ?? self.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: superview?.widthAnchor ?? self.widthAnchor, multiplier: 0.6).isActive = true
        imageView.heightAnchor.constraint(equalTo: superview?.heightAnchor ?? self.heightAnchor, multiplier: 1/2).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: superview?.centerYAnchor ?? self.centerYAnchor, constant: superview?.frame.size.height ?? self.frame.size.height/8).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: superview?.centerXAnchor ?? self.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: superview?.widthAnchor ?? self.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: superview?.heightAnchor ?? self.heightAnchor, multiplier: 1/16).isActive = true
        titleLabel.font = UIFont(name: "Helvetica", size: superview?.frame.size.height ?? self.frame.size.height/16)
        
        detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: superview?.frame.size.height ?? self.frame.size.height/16).isActive = true
        detailsLabel.centerXAnchor.constraint(equalTo: superview?.centerXAnchor ?? self.centerXAnchor).isActive = true
        detailsLabel.widthAnchor.constraint(equalTo: superview?.widthAnchor ?? self.widthAnchor, multiplier: 0.8).isActive = true
        detailsLabel.heightAnchor.constraint(equalTo: superview?.heightAnchor ?? self.heightAnchor, multiplier: 1/8).isActive = true
        detailsLabel.font = UIFont(name: "Helvetica", size: superview?.frame.size.height ?? self.frame.size.height/28)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
