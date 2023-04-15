//
//  DatePickerTableViewCell.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-17.
//

import UIKit
import SwiftDate

struct EventDate {
    let name:String
    let startDate:Date
    let endDate:Date
    
    static let now = DateInRegion(Date(),region: .current)
    
    static let today = EventDate(name: "今天", startDate: Date.startOfTodayLocalTime(), endDate: Date.startOfTomorrowLocalTime())
    static let tomorrow = EventDate(name: "明天", startDate: Date.startOfTomorrowLocalTime(), endDate: Date.startOfTomorrowLocalTime().adding(days: 1))
    static let thisWeek = EventDate(name: "今星期", startDate: Date.startOfThisWeekLocalTime(), endDate: Date.startOfNextWeekLocalTime())
    static let nextWeek = EventDate(name: "下星期", startDate: Date.startOfNextWeekLocalTime(), endDate: Date.startOfTwoWeeksAfterLocalTime())
    static let friday = EventDate(name: "星期五", startDate: now.dateAt(.nextWeekday(.friday)).date, endDate:now.dateAt(.nextWeekday(.saturday)).date - 1 )
    static let weekend = EventDate(name: "週末", startDate: now.dateAt(.nextWeekday(.saturday)).date, endDate:now.dateAt(.nextWeekday(.sunday)).date.adding(days: 1) - 1 )
    
    static let dateArray:[EventDate] = [
        .today,
        .tomorrow,
        .friday,
        .weekend,
        .thisWeek,
        .nextWeek
    ]
}

protocol DatePickerTableViewCellDelegate:AnyObject {
    func DatePickerTableViewCellDelegateOnDateChanged(_ cell:DatePickerTableViewCell, startDate:Date,endDate:Date)
    func DatePickerDidTapAddEndTime(_ cell :DatePickerTableViewCell)
}

class DatePickerTableViewCell: UITableViewCell {
    static let identifier = "DatePickerTableViewCell"
    
    weak var delegate:DatePickerTableViewCellDelegate?
    
    private let startDate:UILabel = {
        let view = UILabel()
        view.text = "開始: "
        
        return view
    }()
    
    private let endDate:UILabel = {
        let view = UILabel()
        view.text = "結束: "
        return view
    }()
    
    let startDay:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .secondaryLabel
        return view
    }()
    let endDay:UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .secondaryLabel
        return view
    }()
    let optionalLabel:UILabel = {
        let view = UILabel()
        view.textColor = .secondaryLabel
        view.font = .systemFont(ofSize: 14)
        view.text = "(選填)"
        return view
    }()
    
    let startDatePicker:UIDatePicker = {
        let view = UIDatePicker()
        view.minimumDate = Date().startOfWeekLocalTime()
        return view
    }()
    
    let endDatePicker:UIDatePicker = {
        let view = UIDatePicker()
        view.minimumDate = Date().startOfWeekLocalTime()
        return view
    }()
    
    
    let switchButton:UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "lessthan.square"), for: .normal)
        view.tintColor = .secondaryLabel
        return view
    }()
    
    private let filterBar:FilterBarCollectionView = {
        let view = FilterBarCollectionView()
        view.objects = EventDate.dateArray
        return view
    }()
    
    private var cellHeightAnchor:NSLayoutConstraint!
    
    private var filterBarHeight:CGFloat = 35
    private var initialHeight:CGFloat = 44 + 45
    private var expandedHeight:CGFloat = 80 + 45
    
    var isExpanded:Bool = false {
        didSet {
            if isExpanded {
                didTapAddEndTime()
            }
        }
    }
    
    // used for edit mode
    var newPost:NewPost? {
        didSet {
            if let newPost = newPost {
                startDatePicker.date = newPost.startDate
                endDatePicker.date = newPost.endDate
                startDay.text = newPost.startDate.weekdayName(.short)
                endDay.text = newPost.endDate.weekdayName(.short)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        selectionStyle = .none
        [startDate,endDate,startDatePicker,endDatePicker,switchButton,filterBar,startDay,endDay].forEach{contentView.addSubview($0) }
        
        
        startDatePicker.addTarget(self, action: #selector(onDateChanged(_:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(onDateChanged(_:)), for: .valueChanged)
        switchButton.addTarget(self, action: #selector(didTapAddEndTime), for: .touchUpInside)
        
        
        switchButton.anchor(
            top: startDatePicker.topAnchor, leading: startDatePicker.trailingAnchor, bottom: startDatePicker.bottomAnchor, trailing: contentView.trailingAnchor,
            padding: .init(top: 0, left: 10, bottom: 0, right: 20))

        cellHeightAnchor = contentView.heightAnchor.constraint(equalToConstant: initialHeight)
        cellHeightAnchor.priority = .defaultHigh
        cellHeightAnchor.isActive = true
        
        startDate.anchor(
            top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil,
            padding: UIEdgeInsets(top: 5, left: 30, bottom: 0, right: 0))

        startDatePicker.anchor(
            top: startDate.topAnchor, leading: nil, bottom: startDate.bottomAnchor,
                               trailing: switchButton.leadingAnchor,
            padding: .init(top: 0, left: 0, bottom: 0, right: 10))
        
        
        startDay.anchor(top: startDate.topAnchor, leading: nil, bottom: startDate.bottomAnchor, trailing: startDatePicker.leadingAnchor,
                        padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        endDay.anchor(top: endDate.topAnchor, leading: nil, bottom: endDate.bottomAnchor, trailing: endDatePicker.leadingAnchor,
                      padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        
        endDate.anchor(
            top: nil, leading: contentView.leadingAnchor, bottom: filterBar.topAnchor, trailing: nil,
            padding: .init(top: 0, left: 30, bottom: 5, right: 0))

        endDatePicker.anchor(
            top: endDate.topAnchor, leading: nil, bottom: endDate.bottomAnchor, trailing: startDatePicker.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 0, right: 0))


        filterBar.anchor(top: nil, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 5, right: 0),
        size: CGSize(width: 0, height: filterBarHeight))

        endDatePicker.isHidden = true
        endDate.isHidden = true
        endDay.isHidden = true
        
        startDate.text = "日期: "
        
        filterBar.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Public Method
    public func configure(mode:UIDatePicker.Mode){
        startDatePicker.datePickerMode = mode
        endDatePicker.datePickerMode = mode
    }
    
    // MARK: - Private Method
    
    @objc private func didTapAddEndTime(toggle:Bool = true){
        
        endDatePicker.isHidden.toggle()
        endDate.isHidden.toggle()
        endDay.isHidden.toggle()
        let isHidden = endDatePicker.isHidden
        
        
        endDatePicker.date = startDatePicker.date
        UIView.animate(withDuration: 0.3) {[weak self] in
            if isHidden {
                self?.cellHeightAnchor.constant = self!.initialHeight
                self?.switchButton.transform = .identity
                self?.startDate.text = "日期: "
            }else {
                self?.cellHeightAnchor.constant = self!.expandedHeight
                self?.switchButton.transform = .init(rotationAngle: .pi*3/2)
                self?.startDate.text = "開始: "
                
            }
        }
        delegate?.DatePickerDidTapAddEndTime(self)
    }
    
    @objc private func onDateChanged(_ sender:UIDatePicker ){
        
        endDatePicker.minimumDate = startDatePicker.date
        
        
        filterBar.reloadData()
        
        startDay.text = String.localeDate(from: startDatePicker.date, .zhHantTW).dayOfWeek
        endDay.text = String.localeDate(from: endDatePicker.date, .zhHantTW).dayOfWeek
        
        delegate?.DatePickerTableViewCellDelegateOnDateChanged(self, startDate: startDatePicker.date, endDate: endDatePicker.date)
    }
}

extension DatePickerTableViewCell : UICollectionViewDelegate {
    // MARK: - Filter Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let eventDate = filterBar.objects[indexPath.row] as? EventDate else { return}
        
        if endDatePicker.isHidden {
            shouldExpand()
        }
        
        startDatePicker.setDate(eventDate.startDate, animated: true)
        endDatePicker.setDate(eventDate.endDate - 1, animated: true)
        
        startDay.text = String.localeDate(from: startDatePicker.date, .zhHantTW).dayOfWeek
        endDay.text = String.localeDate(from: endDatePicker.date, .zhHantTW).dayOfWeek
        
        delegate?.DatePickerTableViewCellDelegateOnDateChanged(self, startDate: startDatePicker.date, endDate: endDatePicker.date)
    }
    
    private func shouldExpand(){
        endDatePicker.isHidden = false
        endDate.isHidden = false
        endDay.isHidden = false
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.cellHeightAnchor.constant = self!.expandedHeight
            self?.switchButton.transform = .init(rotationAngle: .pi*3/2)
            self?.startDate.text = "開始: "
        }
        delegate?.DatePickerDidTapAddEndTime(self)
    }
}
