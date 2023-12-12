//
//  ViewController.swift
//  Nested Compostional Layout
//
//  Created by PhuongDo on 12/12/2023.
//

import UIKit

enum SectionKind: Int, CaseIterable{
    case first
    case second
    case third
    
    var itemCount: Int{
        switch self{
        case .first:
            return 2
        default:
            return 1
        }
    }
    
    var nestedGroupHeight: NSCollectionLayoutDimension{
        switch self{
        case.first:
            return .fractionalWidth(0.9)
        default:
            return .fractionalWidth(0.45)
        }
    }
    
    var orthogonalBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior {
        switch self {
        case .first:
            return .continuous
        case .second:
            return .groupPaging
        case .third:
            return .groupPagingCentered
        }
    }
}

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
    private var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        // Do any additional setup after loading the view.
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
      let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

        guard let sectionKind = SectionKind(rawValue: sectionIndex) else { return nil }

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let itemSpacing: CGFloat = 10
        item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)

        let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
        let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount)

        let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: sectionKind.nestedGroupHeight)
        let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])

        let section = NSCollectionLayoutSection(group: nestedGroup)
        section.orthogonalScrollingBehavior = sectionKind.orthogonalBehaviour

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        return section
      }
      return layout
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            //config cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else{
                fatalError("Dequeue reusable cell fail")
            }
            cell.textLabel.text = "\(item)"
            cell.backgroundColor = .green
            cell.layer.cornerRadius = 10
            return cell
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView,
              let _ = SectionKind(rawValue: indexPath.section) else {
                fatalError()
            }
            headerView.textLabel.textAlignment = .left
            headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            headerView.textLabel.text = "\(SectionKind.allCases[indexPath.section])".capitalized
            return headerView
          }
        
        //initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind,Int>()
        snapshot.appendSections([.first, .second, .third])
        
        snapshot.appendItems(Array(1...20), toSection: .first)
        snapshot.appendItems(Array(21...40), toSection: .second)
        snapshot.appendItems(Array(41...60), toSection: .third)
        
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    

}

