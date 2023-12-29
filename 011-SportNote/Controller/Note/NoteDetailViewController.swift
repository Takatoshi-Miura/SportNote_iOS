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
    @IBOutlet weak var weatherLabel: UILabel!
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
    
    private func initView() {
        dateLabel.text = formatDate(date: viewModel.note.date, format: "yyyy/M/d (E)")
    }

}
