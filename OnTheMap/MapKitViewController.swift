//
//  MapKitViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/10.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit
import MapKit
import Foundation

/**
Derived MKAnnotation class including annotation related student information. An annotation will be shown on the map with the title and subtitle as it is defeined.
*/
final class StudentAnnotation: NSObject, MKAnnotation {
	
	enum Kind {
		case NameAndURL
		case AddressAndURL
	}

	let name: String
	let url: String
	let coordinate: CLLocationCoordinate2D
	
	init(name: String, url: String, coordinates: CLLocationCoordinate2D) {
		self.name = name
		self.url = url
		self.coordinate = coordinates
		super.init()
	}
	
	var title: String? {
		return name
	}
	
	var subtitle: String? {
		return url
	}
}

/**
MapKitViewController controls MKMapView in the container views commonly used in this application. This class provides common features of various operations for the map, putting a markers, moving to some locations, let the delegate class know when a marker is tappped or the map is shown.
*/
final class MapKitViewController: UIViewController, MKMapViewDelegate {
	
	private var sharedApp : AppDelegate!
	private var studentAnnotaions = [StudentAnnotation]() // markers drawn on the map
	var delegate: Updatable?
	
	var markerTapHandler: ((StudentAnnotation?) -> ())!
	var mapShownHandler: (() -> ())!
	
	//private var locationManager: CLLocationManager!
	private var initialLocation: CLLocationCoordinate2D!
	
	private var onViewAppearedFirstTime = true

	// store the last selected location (to shared the same information among different map view controllers)
	// example: 35.6897° N, 139.6922° E
	//private static var lastLocation = CLLocationCoordinate2DMake(35.6897,139.6922)
	private static let DefaultScale = 20.0
	
	var lastLocation = CLLocationCoordinate2DMake(35.6897,139.6922)
	var lastScale = 20.0
	
	@IBOutlet weak var mapView: MKMapView!

	//----------------------------------------------------------------------//
	// ViewController methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.sharedApp = (UIApplication.sharedApplication().delegate as! AppDelegate)
		
		// setup basic map parameters
		self.mapView.delegate = self
		self.mapView.mapType = MKMapType.Standard
		mapView.showsUserLocation = true
		mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewWillAppear(animated)
		//moveToALocation(MapKitViewController.lastLocation, scale: MapKitViewController.lastScale)
		moveToALocation(lastLocation, scale: lastScale)
		// update student locations once to supress the total number of network connections
		delegate?.update(fromWebAPI: onViewAppearedFirstTime)
		if onViewAppearedFirstTime {
			onViewAppearedFirstTime = false
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}

	//----------------------------------------------------------------------//
	// map operation methods
	
	/**
	Show every student locations
	
	:param: method what kind of annotaion should be displayed
	:returns: annotaion object to show
	*/
	func showAllMarkers(method: StudentAnnotation.Kind) -> StudentAnnotation? {
		removeAllMarkers()
		var lastMarker: StudentAnnotation!
		for student in sharedApp.students.array! {
			let marker = createMarker(method, student: student)
			addMarker(marker!)
			if lastMarker == nil {
				lastMarker = marker
			}
		}
		return lastMarker
	}
	
	/**
	Remove all markers from the map
	
	:param: none
	:returns: none
	*/
	func removeAllMarkers() {
		mapView.removeAnnotations(studentAnnotaions)
		studentAnnotaions.removeAll(keepCapacity: false)
	}
	
	/**
	Create a marker which shows specified student information
	
	:param: method The kind of new annotaion
	:returns: Created annotaion object
	*/
	func createMarker(method: StudentAnnotation.Kind, student: StudentInformation?) -> StudentAnnotation? {
		if let student = student {
			switch method {
			case .NameAndURL:
				return StudentAnnotation(
					name: student.firstName + " " + student.lastName,
					url: student.mediaURL,
					coordinates: student.coordinates)
			case .AddressAndURL:
				return StudentAnnotation(
					name: student.mapString,
					url: student.mediaURL,
					coordinates: student.coordinates)
			}
		}
		return nil
	}
	
	/**
	Register a new marker to the map.
	
	:param: marker A marker object to be added
	:returns: Actually added object
	*/
	func addMarker(marker: StudentAnnotation?) -> StudentAnnotation? {
		if let validMarker = marker {
			studentAnnotaions.append(validMarker)
			mapView.addAnnotation(validMarker)
		}
		return marker
	}
	
	/**
	Get a marker object of specified index
	
	:param: index
	:returns: actually added object
	*/
	func getMarker(index: Int) -> StudentAnnotation? {
		if index >= studentAnnotaions.count {
			return nil
		}
		return studentAnnotaions[index]
	}
	
	/**
	Transit to the specified location
	
	:param: marker next location to go
	:param: scale The coordinate span after the transition
	:returns: none
	*/
	func moveToMarker(marker: StudentAnnotation?, scale: Double = MapKitViewController.DefaultScale) {
		selectMarker(marker)
		moveToALocation(marker?.coordinate, scale: scale)
	}
	
	/**
	Select a specified marker object
	
	:param: marker Target marker object
	:returns: none
	*/
	func selectMarker(marker: StudentAnnotation?) {
		mapView.selectAnnotation(marker!, animated: true)
	}
	
	// go to the specified location
	private func moveToALocation(location: CLLocationCoordinate2D?, scale: Double = MapKitViewController.DefaultScale) {
		if let location = location {
			// store latest input values
			lastLocation = location
			lastScale = scale
			
			// transit to the next location
			let coordDelta = scale
			let span = MKCoordinateSpanMake(coordDelta, coordDelta)
			let region = MKCoordinateRegionMake(location, span)
			let animationOptions : UIViewAnimationOptions = [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.OverrideInheritedDuration]
			UIView.animateWithDuration(2.5, delay: 0.0, options: animationOptions,
				animations: {
					self.mapView.setCenterCoordinate(location, animated: true)
					self.mapView.setRegion(region, animated: true);
				}, completion: nil)
		}
	}
	
	//----------------------------------------------------------------------//
	// map view delegate

	// render a marker
	func mapView(mapView: MKMapView,
		viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? StudentAnnotation {
			let identifier = "pin"
			var view: MKPinAnnotationView
			if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
				as? MKPinAnnotationView {
					dequeuedView.annotation = annotation
					view = dequeuedView
			} else {
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				view.calloutOffset = CGPoint(x: -5, y: 5)
				view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
			}
			return view
		}
		return nil
	}

	// on marker tapped
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
		calloutAccessoryControlTapped control: UIControl) {
			let student = view.annotation as! StudentAnnotation
			markerTapHandler?(student)
	}
	
}