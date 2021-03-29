//
//  WaterfallCollectionLayout.swift
//  Test-Flow
//
//  Created by Oleksandr Rypyak on 28/03/2021.
//

import UIKit

protocol WaterfallCollectionLayoutDataSource: class {

	func aspectRatioForItem(at indexPath: IndexPath) -> CGFloat
}

class WaterfallCollectionLayout: UICollectionViewLayout {

	weak var aspectRatioSource: WaterfallCollectionLayoutDataSource?

	init(columns: Int) {
		self.columns = columns
		super.init()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	var columns: Int = 1

	var insets: UIEdgeInsets = .zero

	var spacing: CGFloat = 0.0

	private var layouts: [[CellLayout]] = []

	private var columnWidth: CGFloat {
		guard let width = collectionView?.bounds.width else { return .zero }
		let safeWidth = width - insets.left - insets.right
		let remainingWidth = safeWidth - CGFloat((columns - 1)) * spacing
		return remainingWidth / CGFloat(columns)
	}

	private func resetLayouts() {
		layouts = (1...columns).map { _ in [CellLayout]() }
	}

	private func contentFrame(for column: Int) -> CGRect {
		let x = (columnWidth * CGFloat(column)) + (insets.left) + (spacing * CGFloat(column))
		let y = insets.top
		let width = columnWidth
		let height = collectionViewContentSize.height - insets.top - insets.bottom
		return CGRect(x: x, y: y, width: width, height: height)
	}

	private var nextPosition: (Int, CGPoint) {
		let columnTails = layouts.enumerated().map { ($0.offset, $0.element.last) }
		let topMost = columnTails.min { lhs, rhs in
			let lhsMaxY = lhs.1?.rect.maxY ?? .zero
			let rhsMaxY = rhs.1?.rect.maxY ?? .zero
			return lhsMaxY < rhsMaxY
		}
		let column = topMost?.0 ?? 0
		let lastY = topMost?.1?.rect.maxY ?? .zero
		let point = CGPoint(x: contentFrame(for: column).minX, y: lastY == .zero ? insets.top : lastY + spacing)

		return (column, point)
	}

	// Layout overrides

	override var collectionViewContentSize: CGSize {
		guard let collectionView = collectionView else { return .zero }
		let allLayouts = layouts.reduce([CellLayout](), +)
		let maxYLayout = allLayouts.max { $0.rect.maxY < $1.rect.maxY }
		let size = CGSize(width: collectionView.bounds.width, height: (maxYLayout?.rect.maxY ?? insets.top) + insets.bottom)

		return size
	}

	override func prepare() {
		guard
			let collectionView = collectionView,
			let dataSource = collectionView.dataSource,
			let aspectRatioSource = aspectRatioSource
		else { return }

		resetLayouts()
		let itemsCount = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
		for item in 0..<itemsCount {
			let indexPath = IndexPath(item: item, section: 0)
			let ratio = aspectRatioSource.aspectRatioForItem(at: indexPath)
			let (column, point) = nextPosition
			let layout = CellLayout(rect: CGRect(origin: point, size: CGSize(width: columnWidth, height: columnWidth * ratio)), indexPath: indexPath)
			layouts[column].append(layout)
		}
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let allLayouts = layouts.reduce([CellLayout](), +)
		let visibleLayouts = allLayouts.filter { $0.rect.intersects(rect) }
		let visibleAttributes = visibleLayouts.map { $0.makeAttributes() }
		return visibleAttributes
	}

	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let allLayouts = layouts.reduce([CellLayout](), +)
		let itemLayout = allLayouts.first { $0.indexPath == indexPath }
		let attributes = itemLayout?.makeAttributes()
		return attributes
	}
}

fileprivate struct CellLayout {
	let rect: CGRect
	let indexPath: IndexPath

	static let zero = Self(rect: .zero, indexPath: IndexPath(item: 0, section: 0))

	func makeAttributes() -> UICollectionViewLayoutAttributes {
		let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
		attributes.frame = rect
		return attributes
	}
}
