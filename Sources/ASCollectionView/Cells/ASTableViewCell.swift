// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, *)
class ASTableViewCell: UITableViewCell, ASDataSourceConfigurableCell
{
	var itemID: ASCollectionViewItemUniqueID?
	var hostingController: ASHostingControllerProtocol?
	{
		get { _hostingController }
		set { _hostingController = newValue; attachView() }
	}

	private var _hostingController: ASHostingControllerProtocol?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
	{
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		backgroundColor = nil
		selectionStyle = .none
	}

	required init?(coder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	weak var tableViewController: AS_TableViewController?

	private var hasAppeared: Bool = false // Needed due to the `self-sizing` cell used by UICV
	func willAppear()
	{
		hasAppeared = true
		attachView()
	}

	func didDisappear()
	{
		hasAppeared = false
		detachViews()
	}

	private func attachView()
	{
		guard hasAppeared else { return }
		guard let hcView = hostingController?.viewController.view else
		{
			detachViews()
			return
		}
		if hcView.superview != contentView
		{
			hostingController.map { tableViewController?.addChild($0.viewController) }
			contentView.subviews.forEach { $0.removeFromSuperview() }
			contentView.addSubview(hcView)
			hcView.frame = contentView.bounds
			hostingController?.viewController.didMove(toParent: tableViewController)
		}
	}

	private func detachViews()
	{
		hostingController?.viewController.willMove(toParent: nil)
		contentView.subviews.forEach { $0.removeFromSuperview() }
		hostingController?.viewController.removeFromParent()
	}

	override func prepareForReuse()
	{
		itemID = nil
		isSelected = false
		backgroundColor = nil
		alpha = 1.0
		_hostingController = nil
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()

		if hostingController?.viewController.view.frame != contentView.bounds
		{
			hostingController?.viewController.view.frame = contentView.bounds
			hostingController?.viewController.view.setNeedsLayout()
		}
		hostingController?.viewController.view.layoutIfNeeded()
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize
	{
		guard let hostingController = hostingController else { return CGSize(width: 1, height: 1) }
		hostingController.viewController.view.setNeedsLayout()
		hostingController.viewController.view.layoutIfNeeded()
		let size = hostingController.sizeThatFits(
			in: targetSize,
			maxSize: ASOptionalSize(),
			selfSizeHorizontal: false,
			selfSizeVertical: true)
		return size
	}
}
