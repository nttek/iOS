//
//  DetailsViewController.swift
//  Bookkeeping app
//
//  Created by kustar on 12/9/20.
//  Copyright © 2020 kustar. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class DetailsViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var mapInstLabel: UILabel!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var recenterButton: UIButton!
    
    var books: [Book]?
    var isAdding: Bool?
    var selectedBook: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.books = self.fetchBooks()
        myMap.delegate = self
        myMap.mapType = .satelliteFlyover
        loadBookView()
    }
    
    func loadBookView() {
        
        if isAdding! {
            let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
            tap.cancelsTouchesInView = true
            view.addGestureRecognizer(tap)
            
            nameTextField.placeholder = "Enter Book Name"
            isbnTextField.placeholder = "Enter ISBN number"
            bookImageView.image = UIImage(named: "no-image")
            bookImageView.isUserInteractionEnabled = true
            mapInstLabel.text = "Adjust the pin to the new book's origin location"
            mapInstLabel.backgroundColor = .orange
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            bookImageView.addGestureRecognizer(gesture)
            pinImageView.image = UIImage(systemName: "mappin")
            //recenterButton.isHidden = true
        }
        else {
            doneBarButton.title = ""
            doneBarButton.isEnabled = false
            let book = books![selectedBook!]
            nameTextField.text = book.name
            isbnTextField.text = book.isbn
            nameTextField.isUserInteractionEnabled = false
            isbnTextField.isUserInteractionEnabled = false
            bookImageView.image = UIImage(data: book.image!)
            mapInstLabel.isHidden = true
            recenter(latitude: book.latitude, longitude: book.longitude)
        }
    }
    
    func recenter(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let regionSize: Double = 500
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        myMap.removeAnnotation(annotation)
        myMap.addAnnotation(annotation)
        myMap.setRegion(region, animated: true)
    }
    
    func saveBook() {
        //Create book context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let book = Book(context: context)
        book.name = nameTextField.text
        book.isbn = isbnTextField.text
        
        let location = myMap.centerCoordinate
        book.latitude = location.latitude
        book.longitude = location.longitude
        
        if let imageData = bookImageView.image!.pngData() {
            book.image = imageData
        }
        
        //Save the data
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    @objc func imageTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func didTapRecenter(_ sender: Any) {
        switch !isAdding! {
        case true:
            let book = books![selectedBook!]
            recenter(latitude: book.latitude, longitude: book.longitude)
        default:
            checkLocationService()
            spanOnUserLocation()
        }
    }
    @IBAction func didTapDone(_ sender: Any) {
        
        if nameTextField.text!.isEmpty || isbnTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Incomplete", message: "Please fill in all the required details", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
            
            return
        }
        
        saveBook()
        
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            bookImageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Location services
    let locationManager = CLLocationManager()
    var sizeofRegion: Double = 1000
    
    //MARK: Check location services
    func checkLocationService(){
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkAuthorization()
        }
        
        else {
            print("Location services not enabled")
        }
    }
    
    //MARK: Set up location manager
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //MARK: Check authorization
    func checkAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            myMap.showsUserLocation = true
            spanOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            //locationManager.requestAlwaysAuthorization()
            break
        case .denied:
            //locationManager.requestAlwaysAuthorization()
            break
        default:
            break
        }
    }
    
    //MARK: Span on user location
    func spanOnUserLocation(){
        
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion.init(center: location , latitudinalMeters: sizeofRegion, longitudinalMeters: sizeofRegion )
            myMap.setRegion(region, animated: true)
        }
    }
    
    //MARK: Handling map view updates to match location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: sizeofRegion, longitudinalMeters: sizeofRegion)
        myMap.setRegion(region, animated: true)
    }
}
