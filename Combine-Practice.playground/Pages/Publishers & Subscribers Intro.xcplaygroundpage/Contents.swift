import Combine
import PlaygroundSupport

/** -------------------------------------------------------------------------------------------------------------------------------- */
/**
 Subscribing to a Simple Publisher
 */
[1, 2, 3]
        .publisher
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Something went wrong: \(error)")
            case .finished:
                print("Received Completion")
            }
        }, receiveValue: { value in
            print("Received value \(value)")
        })


/** -------------------------------------------------------------------------------------------------------------------------------- */
/**
    NotificationCenter.Publisher
 */

import UIKit
 
extension Notification.Name {
    static let newEvent = Notification.Name("new_event")
}
 
struct Event {
    let title: String
    let scheduledOn: Date
}
 
let eventPublisher = NotificationCenter.Publisher(center: .default, name: .newEvent, object: nil)
    .map { (notification) -> String? in
        return (notification.object as? Event)?.title ?? ""
    }
 
let theEventTitleLabel = UILabel()

/*
// 1. One way to Subscribe
let newEventLabelSubscriber = Subscribers.Assign(object: theEventTitleLabel, keyPath: \.text)
eventPublisher.subscribe(newEventLabelSubscriber)
*/

// 2. A short version (of subscription done in #1)
eventPublisher.assign(to: \.text, on: theEventTitleLabel)
 
let event = Event(title: "Introduction to Combine Framework", scheduledOn: Date())
NotificationCenter.default.post(name: .newEvent, object: event)
print("Recent event notified is: \(theEventTitleLabel.text!)")


/** -------------------------------------------------------------------------------------------------------------------------------- */
/**
 Timer Subscription
 */
 
var subscription: Cancellable? = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()
    .print("data stream")
    .sink { output in
        print("finished stream with : \(output)")
    } receiveValue: { value in
        print("receive value: \(value)")
    }

RunLoop.main.schedule(after: .init(Date(timeIntervalSinceNow: 5))) {
    print("-- cancel subscription")
//    subscription.cancel()
    subscription = nil
}


/** -------------------------------------------------------------------------------------------------------------------------------- */
/**
 Using @Published to bind values for the changes over time
 */

class AgreementFormVC: UIViewController {
    
    @Published var isNextEnabled: Bool = false
//    private var switchSubscriber: AnyCancellable?
    private var subscribers = Set<AnyCancellable>()
    
    @IBOutlet private weak var acceptAgreementSwitch: UISwitch!
    @IBOutlet private weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save the Cancellable Subscription
        $isNextEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &subscribers) // <-- storing the subscription
    }
 
    @IBAction func didSwitch(_ sender: UISwitch) {
        isNextEnabled = sender.isOn
    }
}

/** -------------------------------------------------------------------------------------------------------------------------------- */
