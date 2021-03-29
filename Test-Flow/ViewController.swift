//
//  ViewController.swift
//  Test-Flow
//
//  Created by Oleksandr Rypyak on 28/03/2021.
//

import UIKit

class ViewController: UIViewController {

	var collectionView: UICollectionView?

	override func viewDidLoad() {
		super.viewDidLoad()

		let layout = WaterfallCollectionLayout(columns: 2)
		layout.insets = UIEdgeInsets(top: 6, left: 20, bottom: 0, right: 20)
		layout.spacing = 10
		layout.aspectRatioSource = self
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		self.collectionView = collectionView
		collectionView.dataSource = self
		collectionView.register(ColorCell.self, forCellWithReuseIdentifier: String(describing: ColorCell.self))

		collectionView.backgroundColor = nil
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
			collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		collectionView?.reloadData()
	}

}

extension ViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 20
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorCell.self), for: indexPath)

		if let cell = cell as? ColorCell {
			cell.label.text = String(indexPath.item)
		}

		return cell
	}
}

extension ViewController: WaterfallCollectionLayoutDataSource {

	func aspectRatioForItem(at indexPath: IndexPath) -> CGFloat {
		return CGFloat([0.5, 0.3, 1.5, 0.7].randomElement() ?? 0.5)
	}
}

class ColorCell: UICollectionViewCell {

	let label = UILabel(frame: .zero)

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(label)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: contentView.topAnchor),
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			label.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			label.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		])
		prepareForReuse()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var intrinsicContentSize: CGSize {
		CGSize(width: 100, height: 300)
	}

	override func prepareForReuse() {
		var random: CGFloat { CGFloat((30...70).randomElement()!) / 100.0 }
		backgroundColor = UIColor(red: random, green: random, blue: random, alpha: 1)
	}
}
