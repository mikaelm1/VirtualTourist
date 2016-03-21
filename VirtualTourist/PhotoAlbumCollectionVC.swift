//
//  PhotoAlbumCollectionVC.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 3/1/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "Cell"

class PhotoAlbumCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var bottomButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    
    var selectedIndexPaths = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var pin: Pin! 
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = []
        //print("FetchRequest; \(fetchRequest)")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            print("Error perfroming fetch: \(error1)")
        }
        print("The pin's latitude is: \(pin.latitude)")
        //print("Pin's photos: \(pin.photos)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        setUpMap()
        print("The pin's photos: \(pin.photos.count)")
        if pin.photos.count == 0 {
            
            print("Pin's photos is empty")
            getPhotosForPin(pin)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func getPhotosForPin(pin: Pin) -> [Photo] {
        print("SearchPhotos in Album")
        var photos = [Photo]()
        Flickr.sharedInstance().taskForLocation(pin) { (result, error) -> Void in
            
            if result == nil {
                print(error)
            } else {
                photos = result!
                performUIUpdatesOnMain({ () -> Void in
                    self.saveContext()
                })
            }
        }
        return photos
    }
    
    func downloadImageForPhoto(photo: Photo) {
        var imageData = NSData()
        imageData = NSData(contentsOfURL: NSURL(string: photo.imageUrl)!)!
        let path = self.pathForUrl(NSURL(string: photo.imageUrl)!.lastPathComponent!)
        
        imageData.writeToFile(path, atomically: true)
        photo.imageData = imageData
        print("Saved to Documents Directory")

    }
    
    func deletePhoto(photo: Photo) {
        let path = pathForUrl((NSURL(string: photo.imageUrl)?.lastPathComponent)!)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
            print("Deleted from Documents Directory")
        } catch {
            print("Photo was not deleted from File Manager: \(error)")
        }
    }
    
    func pathForUrl(url: String) -> String {
        let documentsDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullUrl = documentsDirectoryUrl.URLByAppendingPathComponent(url)
        
        return fullUrl.path!
    }
    
    // MARK: Map View
    
    func setUpMap() {
        map.delegate = self
        
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        map.addAnnotation(annotation)
        
        let latDelta: CLLocationDegrees = 0.2 // the smaller the more zoomed in
        let lonDelta: CLLocationDegrees = 0.2
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let region = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: false)
    }


    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("Number of sections: \(fetchedResultsController.sections!.count)")
        return fetchedResultsController.sections?.count ?? 0
    }

    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        print("Number of cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
        //return 12
        
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("Setting up cell at indexPath \(indexPath.row)")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoAlbumCell

        //let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        //print("The photo is \(photo)")
        configureCell(cell, atIndexPath: indexPath)
 
        return cell
    }
    
    
    func configureCell(cell: PhotoAlbumCell, atIndexPath indexPath: NSIndexPath) {
        print("Count of photos in Pin's array of photos: \(pin.photos.count)")
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        if photo.imageData == nil {
            cell.imageView.image = UIImage(named: "placeholder")
            performUIUpdatesOnMain({ () -> Void in
                self.downloadImageForPhoto(photo)
                cell.imageView.image = UIImage(data: photo.imageData!)
            })
        } else {
            cell.imageView.image = UIImage(data: photo.imageData!)
        }
        //collectionView.reloadData()
        if let _ = selectedIndexPaths.indexOf(indexPath) {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1
        }
        updateButton()
        
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected item at: \(indexPath.item)")
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)! as! PhotoAlbumCell
        
        if let index = selectedIndexPaths.indexOf(indexPath) {
            selectedIndexPaths.removeAtIndex(index)
        } else {
            selectedIndexPaths.append(indexPath)
        }
        configureCell(cell, atIndexPath: indexPath)
        
    }

    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("controllerWillChangeContent")
        insertedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("didChangeObject")
        
        switch type {
        case .Insert:
            print("Inserted an item")
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            print("Deleted item")
            deletedIndexPaths.append(indexPath!)
        case .Update:
            print("Updated item")
            updatedIndexPaths.append(newIndexPath!)
        case .Move:
            print("Moved item")
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("controllerDidChangeContent")
        
        collectionView.performBatchUpdates({ () -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func backToMap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newCollectionRequested(sender: AnyObject) {
        
        if sender.title == Constants.deletePhotos {
            print("Only delete selected photos")
            deleteSelectedPhotos()
        } else {
            deleteAllPhotos()
            getPhotosForPin(pin)
            
        }
        
    }
    
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
            deletePhoto(photo)
        }
        saveContext()
    }
    
    func deleteSelectedPhotos() {
        for indexPath in selectedIndexPaths {
            let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            deletePhoto(photo)
            sharedContext.deleteObject(photo)
        }
        selectedIndexPaths = [NSIndexPath]()
        updateButton()
        saveContext()
    }
    
    func updateButton() {
        if selectedIndexPaths.count > 0 {
            bottomButton.title = Constants.deletePhotos
        } else {
            bottomButton.title = Constants.newCollection
        }
    }
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
}



















