
import Foundation
import RxCoreLocation
import RxSwift
import RxCocoa
import CoreLocation

class Location {
    
    var locationMananger: CLLocationManager = CLLocationManager()
    var bag: DisposeBag = DisposeBag()
    var distance: Double  = 0.0
    let defaultLocationValue: CLLocation = CLLocation(latitude: 42.3601, longitude: 71.0589)
    var totalDistance: BehaviorSubject<Double> = BehaviorSubject<Double>(value: 0.0)
    var locationCoordinates: BehaviorSubject<CLLocation>
    var locationsList = [CLLocation]()
    private var isLocationUpdating = false
    
    init() {
        locationMananger.requestWhenInUseAuthorization()
        locationMananger.startUpdatingLocation()
        isLocationUpdating = true
        locationCoordinates = BehaviorSubject<CLLocation>(value: defaultLocationValue)
        self.totalDistance.onNext(0.0)
    }
    
    
    func subscribeToLocation() {
        print("Subscribing to location")
        if (isLocationUpdating != true) {
            locationMananger.startUpdatingLocation()
            isLocationUpdating = true
        }
        locationMananger.rx
            .location
            .subscribe(onNext: { location in
                guard var location = location else { return }
                if self.locationsList.isEmpty {
                    print("locations list is empty")
                    self.locationsList.append(location
                    )
                }
                print("Locations List size: \(self.locationsList.count)")
                print("LOCATION: latitude: \(location.coordinate.latitude)")
                print("LOCATION: longitude: \(location.coordinate.longitude)")
                guard let lastLocation = self.locationsList.last else { return }
                print("Last Location latitude: \(lastLocation.coordinate.latitude)")
                print("Last Location longitude: \(lastLocation.coordinate.longitude)")
                if (self.checkLocationCoordinatesSame(location, lastLocation)) {
                    print("User located at same point")
                } else {
                    print("User has changed location")
                    self.locationsList.append(location)
                    print("LocationsList size \(self.locationsList.count)")
                    self.totalDistance.onNext(self.calcTotalDistance(of: self.locationsList))
                    self.locationCoordinates.onNext(lastLocation)
                }
            })
            .disposed(by: bag)
    }
    
    func checkLocationCoordinatesSame(_ locA: CLLocation, _ locB: CLLocation) -> Bool {
        if (locA.coordinate.latitude.isEqual(to: locB.coordinate.latitude) && locA.coordinate.longitude.isEqual(to: locB.coordinate.longitude)) {
            return true
        } else {
            return false
        }
    }
    
    func calcTotalDistance(of locations: [CLLocation]) -> CLLocationDistance {
        print("Location Model: Calculating total distance")
        print("Number of locations traveled: \(locations.count)")
        let totalDistance = locations.reduce((0.0, nil), { ($0.0 + $1.distance(from: $0.1 ?? $1), $1) }).0
        print("Total distance: \(totalDistance)")
        return totalDistance
    }

    func stopLocationUpdates() {
       locationMananger.stopUpdatingLocation()
       isLocationUpdating = false
    }
}
