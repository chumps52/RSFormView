//
//  FormTableView.swift
//  RSFormView
//
//  Created by Germán Stábile on 1/25/19.
//  Copyright © 2019 Rootstrap. All rights reserved.
//

import Foundation
import UIKit

public protocol FormViewDelegate: class {
  func didUpdateFields(in formView: FormView, allFieldsValid: Bool)
}

@IBDesignable public class FormView: UIView {
    
  @IBOutlet weak var formTableView: UITableView!
  
  public weak var delegate: FormViewDelegate?
  public var viewModel: FormViewModel?
  public var formConfigurator = FormConfigurator() {
    didSet {
      backgroundColor = formConfigurator.formBackgroundColor
      formTableView.backgroundColor = formConfigurator.formBackgroundColor
      formTableView.isScrollEnabled = formConfigurator.isScrollEnabled
      formTableView.reloadData()
    }
  }
  
  public init(with viewModel: FormViewModel) {
    super.init(frame: CGRect.zero)
    self.viewModel = viewModel
    configureViews()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureViews()
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureViews()
  }
  
  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    configureViews()
  }
  
  /// Updates the error state for every visible FormItems
  public func reloadVisibleCells() {
    for cell in formTableView.visibleCells {
      if let cell = cell as? FormViewCell {
        cell.updateErrorState()
      }
    }
  }
  
  /**
   Marks the field with name equal to *fieldName* as invalid with *error* as error message
   
   - Parameters:
      - fieldName: The name of the field to mark as invalid
      - error: The error message to display for the invalid item
  */
  public func markItemInvalid(fieldName: String, error: String) {
    viewModel?.markItemInvalid(fieldName: fieldName, error: error)
    reloadVisibleCells()
  }
}

extension FormView: FormCellDelegate {
  func didUpdate(data: FormField) {
    checkMatches(updatedField: data)
    reloadVisibleCells()
    delegate?.didUpdateFields(in: self,
                              allFieldsValid: viewModel?.validateFields() ?? false)
  }
}

extension FormView: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return viewModel?.items.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let rowFields = viewModel?.items[indexPath.row].formFields
    
    if let formItem = viewModel?.items[indexPath.row],
      let _ = formItem.attributedText,
        rowFields?.isEmpty ?? true,
        let cell = tableView
          .dequeueReusableCell(withIdentifier: FormTextCell.reuseIdentifier,
                               for: indexPath) as? FormTextCell {
        cell.update(withFormItem: formItem, formConfigurator: formConfigurator)
        return cell
      }
    
    return textFieldCell(forRowAt: indexPath,
                         in: tableView,
                         with: rowFields)
  }
    
}
