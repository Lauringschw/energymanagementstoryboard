import UIKit
import SwiftUI

class ViewControllerHome: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color to a soft neutral tone
        view.backgroundColor = UIColor.systemGray5
        
        // Setup the UI components
        setupTemperatureLabel()
        setupGreetingSection()
        setupEnergyModeSection() // Updated to include UISegmentedControl
        setupEnergyEfficiencySection()
        setupQuickFavoritesSection()
        setupBottomTabBar()
    }
    
    // Temperature at the top right (updated design)
    func setupTemperatureLabel() {
        let temperatureLabel = UILabel()
        temperatureLabel.text = "23°"
        temperatureLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy) // Larger and bold
        temperatureLabel.textAlignment = .right
        temperatureLabel.textColor = UIColor.darkGray // Darker gray text for better contrast
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(temperatureLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            temperatureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Greeting Section (updated design)
    func setupGreetingSection() {
        let greetingLabel = UILabel()
        greetingLabel.text = "Good Morning, John!"
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 32)
        greetingLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Today looks great for energy saving."
        subtitleLabel.font = UIFont.systemFont(ofSize: 18) // Slightly larger font
        subtitleLabel.textColor = UIColor.darkGray.withAlphaComponent(0.8) // Muted dark gray for better readability
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(greetingLabel)
        view.addSubview(subtitleLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    // Energy Mode Section with UISegmentedControl (updated design)
    func setupEnergyModeSection() {
        let energyModeLabel = UILabel()
        energyModeLabel.text = "Energy Mode"
        energyModeLabel.font = UIFont.boldSystemFont(ofSize: 24)
        energyModeLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        energyModeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create UISegmentedControl with improved design
        let energyModeSegmentedControl = UISegmentedControl(items: ["Automatic", "Home", "Away", "Sleep"])
        energyModeSegmentedControl.selectedSegmentIndex = 0 // Default to "Home"
        energyModeSegmentedControl.tintColor = UIColor.green // Button tint in green
        energyModeSegmentedControl.backgroundColor = UIColor.white
        energyModeSegmentedControl.layer.cornerRadius = 10 // Rounded corners for modern look
        energyModeSegmentedControl.selectedSegmentTintColor = UIColor.green.withAlphaComponent(0.5) // Softer green
        energyModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        energyModeSegmentedControl.addTarget(self, action: #selector(energyModeChanged(_:)), for: .valueChanged)
        
        view.addSubview(energyModeLabel)
        view.addSubview(energyModeSegmentedControl)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            energyModeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 160),
            energyModeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            energyModeSegmentedControl.topAnchor.constraint(equalTo: energyModeLabel.bottomAnchor, constant: 10),
            energyModeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            energyModeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Method to handle changes in energy mode selection
    @objc func energyModeChanged(_ sender: UISegmentedControl) {
        let selectedMode = sender.titleForSegment(at: sender.selectedSegmentIndex)
        print("Selected Energy Mode: \(selectedMode ?? "Home")")
        // Handle the logic for energy mode change (e.g., update state, perform actions)
    }
    
    
    // Energy Efficiency Section (updated layout with more space)
    // Energy Efficiency Section (updated colors)
    func setupEnergyEfficiencySection() {
        let efficiencyCircle = UIView()
        efficiencyCircle.backgroundColor = UIColor.green
        efficiencyCircle.layer.cornerRadius = 50
        efficiencyCircle.translatesAutoresizingMaskIntoConstraints = false
        
        let efficiencyLabel = UILabel()
        efficiencyLabel.text = "70%"
        efficiencyLabel.font = UIFont.boldSystemFont(ofSize: 30)
        efficiencyLabel.textColor = UIColor.darkGray
        efficiencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let efficiencyText = UILabel()
        efficiencyText.text = "Good Job!\nKeep up the great work, John. Your efforts are making a difference!"
        efficiencyText.font = UIFont.systemFont(ofSize: 16)
        efficiencyText.numberOfLines = 0
        efficiencyText.textColor = UIColor.systemBlue.withAlphaComponent(0.8)
        efficiencyText.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(efficiencyCircle)
        view.addSubview(efficiencyLabel)
        view.addSubview(efficiencyText)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            efficiencyCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: 305),
            efficiencyCircle.widthAnchor.constraint(equalToConstant: 100),
            efficiencyCircle.heightAnchor.constraint(equalToConstant: 100),
            efficiencyCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            efficiencyLabel.centerXAnchor.constraint(equalTo: efficiencyCircle.centerXAnchor),
            efficiencyLabel.centerYAnchor.constraint(equalTo: efficiencyCircle.centerYAnchor),
            
            efficiencyText.leadingAnchor.constraint(equalTo: efficiencyCircle.trailingAnchor, constant: 20),
            efficiencyText.centerYAnchor.constraint(equalTo: efficiencyCircle.centerYAnchor),
            efficiencyText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }


    
    // Quick Favorites Section (updated design)
    func setupQuickFavoritesSection() {
        let quickFavoritesLabel = UILabel()
        quickFavoritesLabel.text = "Quick Favorites"
        quickFavoritesLabel.font = UIFont.boldSystemFont(ofSize: 22)
        quickFavoritesLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        quickFavoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(quickFavoritesLabel)
        
        let buttonLabels = ["Living Room", "Kitchen", "Pool Pump", "Bedroom Lights", "Add Favorite"]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        var currentRow: UIStackView?
        
        for (index, label) in buttonLabels.enumerated() {
            if index % 3 == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.spacing = 16
                stackView.addArrangedSubview(currentRow!)
            }
            
            let button = createFavoriteButton(with: label)
            // Handle navigation for "Kitchen"
                        if label == "Kitchen" {
                            button.addTarget(self, action: #selector(navigateToNoAiThermoView), for: .touchUpInside)
                        }
                        
                        if label == "Living Room"{
                            button.addTarget(self, action: #selector(navigateToAiThermoView), for: .touchUpInside)
                        }
                        
            currentRow?.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        
        // Create the "Smart Suggestions" button
        let smartSuggestionsButton = UIButton(type: .system)
        smartSuggestionsButton.setTitle("Smart Suggestions", for: .normal)
        smartSuggestionsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        smartSuggestionsButton.setTitleColor(UIColor.white, for: .normal)
        smartSuggestionsButton.backgroundColor = UIColor.systemBlue // Use blue to signify AI
        smartSuggestionsButton.layer.cornerRadius = 10
        smartSuggestionsButton.layer.shadowColor = UIColor.black.cgColor
        smartSuggestionsButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        smartSuggestionsButton.layer.shadowOpacity = 0.2
        smartSuggestionsButton.layer.shadowRadius = 8
        smartSuggestionsButton.translatesAutoresizingMaskIntoConstraints = false
        smartSuggestionsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true // Adjust button height
        smartSuggestionsButton.addTarget(self, action: #selector(smartSuggestionsTapped), for: .touchUpInside)
        
        // Create an AI icon for the button
        let aiIcon = UIImageView(image: UIImage(systemName: "brain.head.profile"))
        aiIcon.tintColor = .white
        aiIcon.translatesAutoresizingMaskIntoConstraints = false
        aiIcon.contentMode = .scaleAspectFit
        
        // Add AI icon to the button
        smartSuggestionsButton.addSubview(aiIcon)
        
        // Create description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Get personalized recommendations based on your habits."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIColor.darkGray.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(descriptionLabel)

        view.addSubview(smartSuggestionsButton)

        NSLayoutConstraint.activate([
            quickFavoritesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 440),
            quickFavoritesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            stackView.topAnchor.constraint(equalTo: quickFavoritesLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            smartSuggestionsButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            smartSuggestionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            smartSuggestionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            aiIcon.centerYAnchor.constraint(equalTo: smartSuggestionsButton.centerYAnchor),
            aiIcon.leadingAnchor.constraint(equalTo: smartSuggestionsButton.leadingAnchor, constant: 16),
            aiIcon.widthAnchor.constraint(equalToConstant: 24),
            aiIcon.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.topAnchor.constraint(equalTo: smartSuggestionsButton.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // Action for Smart Suggestions button
    @objc func smartSuggestionsTapped() {
        let smartSuggestionsVC = SmartSuggestionsViewController()
        smartSuggestionsVC.modalPresentationStyle = .fullScreen
        self.present(smartSuggestionsVC, animated: true, completion: nil)
        
    }
    

    
    // Create custom favorite button (updated design)
    func createFavoriteButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.darkGray.withAlphaComponent(0.8), for: .normal) // Softer green
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true // Adjust button height
            button.widthAnchor.constraint(equalToConstant: 120).isActive = true // Adjust button width
        
        return button
    }
    
    // Setup bottom tab bar with updated colors and design
    func setupBottomTabBar() {
        let tabBarView = UIView()
        tabBarView.backgroundColor = UIColor.white
        tabBarView.layer.cornerRadius = 20
        tabBarView.layer.shadowColor = UIColor.black.cgColor
        tabBarView.layer.shadowOffset = CGSize(width: 0, height: 4)
        tabBarView.layer.shadowOpacity = 0.1
        tabBarView.layer.shadowRadius = 10
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tabBarView)
        
        let tabStackView = UIStackView()
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.spacing = 20
        tabStackView.translatesAutoresizingMaskIntoConstraints = false

        
        let tabItems = [("Home", "house.fill"), ("Devices", "rectangle.connected.to.line.below"), ("Activity", "chart.bar.fill"), ("Notifications", "bell")]
        
        for (title, imageName) in tabItems {
            let button = createTabBarButton(with: title, imageName: imageName)
            tabStackView.addArrangedSubview(button)
        }
        
        view.addSubview(tabBarView)
        view.addSubview(tabStackView)
        
        NSLayoutConstraint.activate([
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabBarView.heightAnchor.constraint(equalToConstant: 60),
            
            tabStackView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            tabStackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            tabStackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            tabStackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor)
        ])
    }
    
    // Helper function to create tab bar buttons
    func createTabBarButton(with title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .black
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: -30)
        button.titleEdgeInsets = UIEdgeInsets(top: 40, left: -40, bottom: 0, right: 0)
        return button
    }
    
    // Action to navigate to aiThermostat Storyboard
     @objc func navigateToAiThermoView() {
         // Assuming aiThermostat is your storyboard name
         let thermostatStoryboard = UIStoryboard(name: "AiThermostat", bundle: nil)
         let thermoVC = thermostatStoryboard.instantiateViewController(withIdentifier: "aiThermo")
         thermoVC.modalPresentationStyle = .fullScreen
         self.present(thermoVC, animated: true, completion: nil)
     }
     
     @objc func navigateToNoAiThermoView() {
         // Assuming NoAiThermoView is a SwiftUI view
         let thermostatStoryboard = UIStoryboard(name: "NoaiThermostat", bundle: nil)
         let thermoVC = thermostatStoryboard.instantiateViewController(withIdentifier: "noAiThermo")
         thermoVC.modalPresentationStyle = .fullScreen
         self.present(thermoVC, animated: true, completion: nil)
     }
 }

