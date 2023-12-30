//
//  NoteDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/12/27.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NoteDetailViewController: UIViewController {

    // MARK: - UI,Variable
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionText: UILabel!
    @IBOutlet weak var purposeArea: UIStackView!
    @IBOutlet weak var purposeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var purposeText: UILabel!
    @IBOutlet weak var detailArea: UIStackView!
    @IBOutlet weak var detailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailText: UILabel!
    private var viewModel: NoteDetailViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(note: Note) {
        self.viewModel = NoteDetailViewModel(note: note)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    // MARK: - Other Methods
    
    /// 画面にノート内容をセット
    private func initView() {
        dateLabel.text = formatDate(date: viewModel.note.date, format: "yyyy/M/d (E)")
        temperatureLabel.text = String(viewModel.note.temperature) + "℃"
        weatherImage.image = Weather.allCases[viewModel.note.weather].image
        conditionLabel.text = TITLE_CONDITION
        conditionText.text = viewModel.note.condition
        if viewModel.note.noteType == NoteType.practice.rawValue {
            purposeLabel.text = TITLE_PRACTICE_PURPOSE
            purposeText.text = viewModel.note.purpose
            detailLabel.text = TITLE_DETAIL
            detailText.text = viewModel.note.detail
        } else {
            purposeArea.isHidden = true
            purposeLabel.isHidden = true
            purposeText.isHidden = true
            purposeHeightConstraint.constant = 0
            detailArea.isHidden = true
            detailLabel.isHidden = true
            detailText.isHidden = true
            detailHeightConstraint.constant = 0
        }
    }

}
