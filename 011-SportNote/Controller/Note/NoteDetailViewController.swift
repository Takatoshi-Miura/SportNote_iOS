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
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reflectionLabel: UILabel!
    @IBOutlet weak var reflectionText: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
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
        initTableView()
    }
    
    // MARK: - Other Methods
    
    /// 画面にノート内容をセット
    private func initView() {
        dateLabel.text = formatDate(date: viewModel.note.date, format: "yyyy/M/d (E)")
        temperatureLabel.text = String(viewModel.note.temperature) + "℃"
        weatherImage.image = Weather.allCases[viewModel.note.weather].image
        conditionLabel.text = TITLE_CONDITION
        conditionText.text = viewModel.note.condition
        taskLabel.text = TITLE_TACKLED_TASK
        reflectionLabel.text = TITLE_REFLECTION
        reflectionText.text = viewModel.note.reflection
        if viewModel.note.noteType == NoteType.practice.rawValue {
            purposeLabel.text = TITLE_PRACTICE_PURPOSE
            purposeText.text = viewModel.note.purpose
            detailLabel.text = TITLE_DETAIL
            detailText.text = viewModel.note.detail
        } else {
            purposeLabel.text = TITLE_TARGET
            purposeText.text = viewModel.note.target
            detailLabel.text = TITLE_CONSCIOUSNESS
            detailText.text = viewModel.note.consciousness
            taskLabel.isHidden = true
            tableView.isHidden = true
        }
    }
    
    /// TableView初期化
    private func initTableView() {
        tableView.register(UINib(nibName: "TaskCellForAddNote", bundle: nil), forCellReuseIdentifier: "TaskCellForAddNote")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        if viewModel.taskArray.isEmpty {
            tableView.separatorStyle = .none
        }
        resizeScrollView()
    }
    
    /// スクロール領域を調整
    private func resizeScrollView() {
        var tableHeight = CGFloat(0)
        if viewModel.taskArray.isEmpty {
            tableHeight = CGFloat(44)
        } else {
            tableHeight = CGFloat(viewModel.taskArray.count * 200)
        }
        tableViewHeightConstraint.constant = tableHeight
        scrollViewHeightConstraint.constant = CGFloat(1000 + tableHeight)
    }

}

extension NoteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.taskArray.isEmpty ? 1 : viewModel.taskArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.taskArray.isEmpty ? 44 : 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.taskArray.isEmpty {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = MESSAGE_DONE_TASK_EMPTY
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellForAddNote", for: indexPath) as! TaskCellForAddNote
            cell.printInfo(task: viewModel.taskArray[indexPath.row])
            cell.printMemo(memo: viewModel.memoArray[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
