//
//  SegmentedButtonsView.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-10.
//

import UIKit


protocol CollectionViewDidScrollDelegate:AnyObject {
    func collectionViewDidScroll(for x: CGFloat)
    
}

protocol SegmentedControlDelegate:AnyObject {
    func didIndexChanged(at index:Int)
}

class SegmentedButtonsView: UIView{
    
    //MARK: - properties
    
    lazy var selectorView = UIView()
    lazy var labels = [UILabel]()
    private var titles: [String]!
    var textColor = UIColor.lightGray
    var selectorTextColor = UIColor.label
    
    public private(set) var selectedIndex: Int = 0
    
    weak var delegate: SegmentedControlDelegate?
    
    convenience init(frame: CGRect, titles: [String]) {
        self.init(frame:frame)
        self.titles = titles
    }
    
    //MARK: - config selected Tap
    
    private func configSelectedTap(){
        let segmentsCount = CGFloat(titles.count)
        let selectorWidth = self.frame.width / segmentsCount
        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height - 0.8, width: selectorWidth, height: 1))
        selectorView.backgroundColor = .mainColor
        addSubview(selectorView)
    }
    
    //MARK: - create lables
    
    private func createLables(){
        
        labels.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        for lableTitle in titles{
            
            let lable = UILabel()
            lable.font = UIFont.systemFont(ofSize: 18)
            lable.text = lableTitle
            let tapGestureRecognizor = UITapGestureRecognizer(target: self, action: #selector(labelActionHandler(sender:)))
            tapGestureRecognizor.numberOfTapsRequired = 1
            lable.addGestureRecognizer(tapGestureRecognizor)
            lable.isUserInteractionEnabled = true
            
            lable.textColor = textColor
            lable.textAlignment = .center
            labels.append(lable)
        }
        labels[0].textColor = selectorTextColor
    }
    
    //MARK: - set lables titles
    
    func setLablesTitles(titles:[String]){
        
        self.titles = titles
        self.updateView()
        
    }
    
    //MARK: - config stackView
    
    private func configStackView(){
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
    }
    
    //MARK: - updateView
    
    private func updateView(){
        createLables()
        configSelectedTap()
        configStackView()
    }
    
    //MARK: - draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
    
    
    @objc private func labelActionHandler(sender:UITapGestureRecognizer){
           for (labelIndex, lbl) in labels.enumerated() {
               if lbl == sender.view{
                   selectedIndex = labelIndex
                   delegate?.didIndexChanged(at: selectedIndex)
               }
           }
        
        
       }
    
}

extension SegmentedButtonsView:CollectionViewDidScrollDelegate {
    
    
    func collectionViewDidScroll(for x: CGFloat) {
        
        UIView.animate(withDuration: 0.1) { [self] in
            self.selectorView.frame.origin.x = x
            
            for (_,view)in subviews.enumerated(){
                
                if view is UIStackView{
                    
                    guard let stack = view as? UIStackView else { return }
                    
                    for (_,label) in stack.arrangedSubviews.enumerated(){
                        
                        guard let label = label as? UILabel else {
                            print("Error ")
                            return
                        }
                        
                        if  (label.frame.width / 2  >= self.selectorView.frame.origin.x && titles[0] == label.text! || label.frame.width / 2  <= self.selectorView.frame.origin.x && titles[1] == label.text! ) {
                            
                            label.textColor = selectorTextColor
                            
                        }else{
                            
                            label.textColor = textColor
                        }
                        
                    }
                }
            }
        }
    }
    
}
