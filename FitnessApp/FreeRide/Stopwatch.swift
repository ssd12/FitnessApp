import Foundation
import RxSwift

class Stopwatch {
    
    var timeElapsed: Double = 0.0
    var timeAtCompletion: Double = 0.0
    var timeAtPause: Double = 0.0
    var timerOn = false
    var timerPaused = false
    var timer = Timer()
    var elapsedTimeSubject = BehaviorSubject<Double>(value: 0.0)
    
    init() {
        
    }
    
    func startStopWatch() {
        print("Starting stopwatch")
        self.timerOn = true
        if (timerPaused) {
            timeElapsed = timeAtPause
            timer =  Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateElapsedTime), userInfo: nil, repeats: true)
            timerPaused = false
        } else {
             timer =  Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateElapsedTime), userInfo: nil, repeats: true)
        }
    }
    
    func stopStopWatch() {
        if (timerPaused) {
            //do nothing
        } else {
            pauseStopWatch()
        }
    }
    
    func pauseStopWatch() {
        if (timerPaused) {
            //do nothing
        } else {
            self.timeAtPause = self.timeElapsed
            timer.invalidate()
            self.timerPaused = true
        }
    }
    
    func resetRide() {
        self.timeElapsed = 0.0
        self.timer.invalidate()
        self.timerOn = false
        self.timerPaused = false
        elapsedTimeSubject.onNext(0.0)
    }
    
    @objc func updateElapsedTime() {
        self.timeElapsed = self.timeElapsed+0.1
        self.timeElapsed = Double(round(100*self.timeElapsed)/100)
        self.elapsedTimeSubject.onNext(self.timeElapsed)
    }
}
