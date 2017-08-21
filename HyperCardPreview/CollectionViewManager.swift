//
//  CollectionViewManager.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 21/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon


public class CollectionViewManager: NSObject, NSCollectionViewDataSource {
    
    private let collectionView: NSCollectionView
    
    private let browser: Browser
    
    private var thumbnails: [NSImage?]
    
    private let renderingQueue: DispatchQueue
    
    private var renderingPriorities: [Int]
    
    private var currentPriority = 0
    
    private static let itemIdentifier = "item"
    
    public init(collectionView: NSCollectionView, stack: Stack) {
        self.collectionView = collectionView
        self.browser = Browser(stack: stack)
        self.thumbnails = [NSImage?](repeating: nil, count: stack.cards.count)
        self.renderingQueue = DispatchQueue(label: "CollectionViewManager Rendering Queue")
        self.renderingPriorities = [Int](repeating: 0, count: stack.cards.count)
        
        super.init()
        
        /* Register as data source */
        let nib = NSNib(nibNamed: "CardItem", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: CollectionViewManager.itemIdentifier)
        collectionView.dataSource = self
        
        collectionView.selectItems(at: Set<IndexPath>([IndexPath(item: 0, section: 0)]), scrollPosition: NSCollectionViewScrollPosition.centeredVertically)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return browser.stack.cards.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = self.collectionView.makeItem(withIdentifier: CollectionViewManager.itemIdentifier, for: indexPath)
        
        if let image = thumbnails[indexPath.item] {
            item.imageView!.image = image
        }
        else {
            item.imageView!.image = nil
            
            currentPriority += 1
            self.renderingPriorities[indexPath.item] = currentPriority
            
            self.renderingQueue.async {
                [unowned self] in
                let cardIndex = self.renderingPriorities.lazy.enumerated().max(by: { (x0: (Int, Int), x1: (Int, Int)) -> Bool in
                    return x0.1 < x1.1
                })!.0
                
                self.browser.cardIndex = cardIndex
                self.browser.refresh()
                self.thumbnails[cardIndex] = self.browser.image.convertToRgb()
                let indexPathUpdated = IndexPath(item: cardIndex, section: 0)
                let indexSet = Set<IndexPath>([indexPathUpdated])
                
                self.renderingPriorities[cardIndex] = 0
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: indexSet)
                }
            }
        }
        
        return item
    }
    
}
