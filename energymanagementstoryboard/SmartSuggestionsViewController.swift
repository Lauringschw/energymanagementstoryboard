import UIKit

class SmartSuggestionsViewController: UIViewController {
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let titleLabel = UILabel()
    let dynamicSuggestionCard = UIView()
    let suggestionDynamicLabel = UILabel()
    let progressMeterView = UIView()
    let energyInsightLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        
        // Setup the UI components
        setupTitleLabel()
        setupProgressMeter()
        setupEnergyInsightLabel()
        setupDynamicSuggestions()
        setupSuggestionsList()
        setupLoadingIndicator()
        setupBackButton()
        setupRefreshButton()
        
        // Simulate fetching suggestions
        fetchSuggestions()
    }

    // Title for the Suggestions Page
    func setupTitleLabel() {
        titleLabel.text = "Smart Suggestions"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // Circular Progress Meter
    func setupProgressMeter() {
        let progressCircle = createCircularProgressBar(percentage: 0.75) // 75% energy usage
        progressMeterView.addSubview(progressCircle)
        progressMeterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressMeterView)
        
        NSLayoutConstraint.activate([
            progressMeterView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            progressMeterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressMeterView.widthAnchor.constraint(equalToConstant: 150),
            progressMeterView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // Energy Insight Label (below the progress meter)
    func setupEnergyInsightLabel() {
        energyInsightLabel.text = "Your energy consumption is 15% lower than last week."
        energyInsightLabel.font = UIFont.systemFont(ofSize: 16)
        energyInsightLabel.textColor = UIColor.darkGray
        energyInsightLabel.textAlignment = .center
        energyInsightLabel.numberOfLines = 0
        energyInsightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(energyInsightLabel)
        
        NSLayoutConstraint.activate([
            energyInsightLabel.topAnchor.constraint(equalTo: progressMeterView.bottomAnchor, constant: 10),
            energyInsightLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            energyInsightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // Dynamic Smart Suggestion Card
    func setupDynamicSuggestions() {
        dynamicSuggestionCard.backgroundColor = UIColor.white
        dynamicSuggestionCard.layer.cornerRadius = 10
        dynamicSuggestionCard.layer.shadowColor = UIColor.black.cgColor
        dynamicSuggestionCard.layer.shadowOpacity = 0.1
        dynamicSuggestionCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        dynamicSuggestionCard.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dynamicSuggestionCard)
        
        suggestionDynamicLabel.text = getSmartSuggestion(for: "leaving_for_work")
        suggestionDynamicLabel.font = UIFont.systemFont(ofSize: 16)
        suggestionDynamicLabel.numberOfLines = 0
        suggestionDynamicLabel.textColor = UIColor.darkGray
        suggestionDynamicLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dynamicSuggestionCard.addSubview(suggestionDynamicLabel)
        
        NSLayoutConstraint.activate([
            dynamicSuggestionCard.topAnchor.constraint(equalTo: energyInsightLabel.bottomAnchor, constant: 20),
            dynamicSuggestionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dynamicSuggestionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dynamicSuggestionCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            suggestionDynamicLabel.topAnchor.constraint(equalTo: dynamicSuggestionCard.topAnchor, constant: 20),
            suggestionDynamicLabel.leadingAnchor.constraint(equalTo: dynamicSuggestionCard.leadingAnchor, constant: 20),
            suggestionDynamicLabel.trailingAnchor.constraint(equalTo: dynamicSuggestionCard.trailingAnchor, constant: -20),
            suggestionDynamicLabel.bottomAnchor.constraint(equalTo: dynamicSuggestionCard.bottomAnchor, constant: -20)
        ])
    }

    // General Suggestions List with "cards"
    // Inside the setupSuggestionsList function
    func setupSuggestionsList() {
        let suggestionLabel = UILabel()
        suggestionLabel.text = "Here are some additional suggestions:"
        suggestionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        suggestionLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        suggestionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(suggestionLabel)
        
        NSLayoutConstraint.activate([
            suggestionLabel.topAnchor.constraint(equalTo: dynamicSuggestionCard.bottomAnchor, constant: 20),
            suggestionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            suggestionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Suggestions displayed in "cards"
        let suggestions = [
            "In the morning the kitchen temperature should be lowed by 2°.",
            "You left the home so turn off lights in the bedroom",
            "Schedule the pool pump to run at night for optimal energy savings."
        ]
        
        var lastView: UIView = suggestionLabel
        for suggestion in suggestions {
            let cardView = createSuggestionCard(withText: suggestion)
            view.addSubview(cardView)
            
            NSLayoutConstraint.activate([
                cardView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 15),
                cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
            
            lastView = cardView
        }
        
        // Add the button for turning off an unused device
        setupTurnOffDeviceButton(below: lastView)
    }

    // New method to create the Turn Off Device button
    // Modified setupTurnOffDeviceButton method
    func setupTurnOffDeviceButton(below view: UIView) {
        let turnOffButton = UIButton(type: .system)
        turnOffButton.setTitle("Turn Off Unused Devices", for: .normal)
        turnOffButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        turnOffButton.backgroundColor = UIColor.systemRed
        turnOffButton.tintColor = UIColor.white
        turnOffButton.layer.cornerRadius = 10
        turnOffButton.addTarget(self, action: #selector(turnOffDeviceButtonTapped), for: .touchUpInside)
        turnOffButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(turnOffButton)
        
        NSLayoutConstraint.activate([
            turnOffButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 20), // Position below the last card
            turnOffButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            turnOffButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            turnOffButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add the informational message below the button
        setupAIMessage(below: turnOffButton)
    }

    // New method to create the AI message label
    func setupAIMessage(below button: UIButton) {
        let aiMessageLabel = UILabel()
        aiMessageLabel.text = "AI automatically decides which unused devices should be turned off based on your activity."
        aiMessageLabel.font = UIFont.systemFont(ofSize: 14)
        aiMessageLabel.textColor = UIColor.darkGray
        aiMessageLabel.numberOfLines = 0
        aiMessageLabel.textAlignment = .center
        aiMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(aiMessageLabel)
        
        NSLayoutConstraint.activate([
            aiMessageLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10), // Position below the button
            aiMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aiMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }


    // Button Action Method
    @objc func turnOffDeviceButtonTapped() {
        // Add your logic for turning off an unused device here
        print("Turning off unused device...")
        // Show an alert or feedback to the user
        let alert = UIAlertController(title: "Device Control", message: "The unused device has been turned off.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }


    // Helper method to create suggestion "cards"
    func createSuggestionCard(withText text: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let suggestionLabel = UILabel()
        suggestionLabel.text = text
        suggestionLabel.font = UIFont.systemFont(ofSize: 16)
        suggestionLabel.textColor = UIColor.darkGray
        suggestionLabel.numberOfLines = 0
        suggestionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(suggestionLabel)
        
        NSLayoutConstraint.activate([
            suggestionLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 15),
            suggestionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            suggestionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            suggestionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -15)
        ])
        
        return cardView
    }

    // Circular Progress Bar Helper Function
    // Improved Circular Progress Bar Helper Function
    func createCircularProgressBar(percentage: CGFloat) -> UIView {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 75, y: 75), radius: 60, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi * percentage - CGFloat.pi / 2, clockwise: true)

        // Background Circle Layer (grey background for comparison)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = UIBezierPath(arcCenter: CGPoint(x: 75, y: 75), radius: 60, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        backgroundLayer.strokeColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 15
        backgroundLayer.fillColor = UIColor.clear.cgColor

        // Gradient Progress Circle
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        gradientLayer.colors = [UIColor.systemGreen.cgColor, UIColor.systemYellow.cgColor, UIColor.systemRed.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.white.cgColor // This color is irrelevant as it's replaced by the gradient
        progressLayer.lineWidth = 15
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        gradientLayer.mask = progressLayer

        // Create a container view for the progress bar
        let progressView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        progressView.layer.addSublayer(backgroundLayer)
        progressView.layer.addSublayer(gradientLayer)

        // AI Icon (animated)
        let aiIcon = UIImageView(image: UIImage(systemName: "brain.fill")) // Choose an appropriate AI icon
        aiIcon.tintColor = UIColor.systemBlue
        aiIcon.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(aiIcon)

        NSLayoutConstraint.activate([
            aiIcon.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            aiIcon.centerYAnchor.constraint(equalTo: progressView.centerYAnchor, constant: -10),
            aiIcon.widthAnchor.constraint(equalToConstant: 30),
            aiIcon.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Percentage Label
        let percentageLabel = UILabel()
        percentageLabel.text = "\(Int(percentage * 100))%"
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 25)
        percentageLabel.textColor = UIColor.systemBlue
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(percentageLabel)

        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor, constant: 20)
        ])

        // Label for usage description (Low, Moderate, High)
        let usageLabel = UILabel()
        usageLabel.text = usageLevel(for: percentage) // Helper function to determine usage level
        usageLabel.font = UIFont.systemFont(ofSize: 14)
        usageLabel.textColor = UIColor.darkGray
        usageLabel.textAlignment = .center
        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(usageLabel)

        NSLayoutConstraint.activate([
            usageLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            usageLabel.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -10)
        ])

        return progressView
    }


    // Helper function to determine the usage level based on percentage
    func usageLevel(for percentage: CGFloat) -> String {
        switch percentage {
        case 0..<0.33:
            return "Low Energy Usage"
        case 0.33..<0.66:
            return "Moderate Energy Usage"
        default:
            return ""
        }
    }


    // Dynamic Smart Suggestions Logic
    func getSmartSuggestion(for userActivity: String) -> String {
        switch userActivity {
        case "leaving_for_work":
            return "Consider switching to 'Automatic' to save energy."
        case "coming_home":
            return "Welcome back! Adjusting your settings to 'Home Mode'."
        case "going_to_bed":
            return "It's bedtime! How about switching off unused appliances?"
        default:
            return "No specific suggestions right now."
        }
    }

    // Loading Indicator
    // Loading Indicator
    func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 40),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
    }


    // Back Button
    func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        backButton.backgroundColor = UIColor.systemBlue
        backButton.tintColor = UIColor.white
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // Refresh Button
    func setupRefreshButton() {
        let refreshButton = UIButton(type: .system)
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        refreshButton.backgroundColor = UIColor.systemGreen
        refreshButton.tintColor = UIColor.white
        refreshButton.layer.cornerRadius = 10
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            refreshButton.widthAnchor.constraint(equalToConstant: 80),
            refreshButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // Fetch Suggestions (simulate a network call)
    func fetchSuggestions() {
        loadingIndicator.startAnimating()
        
        // Simulate a delay to mimic fetching data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadingIndicator.stopAnimating()
            // Here, you would typically update the suggestions based on AI response
        }
    }

    // Back Button Action
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    // Refresh Button Action
    @objc func refreshButtonTapped() {
        fetchSuggestions()
    }
}
