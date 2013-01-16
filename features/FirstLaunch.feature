Feature: Joyn First Launch Feature

Scenario: Accept Joyn terms and condition
Given joyn app is running for the first time on both the devices
Then I accept terms and condition on the devices
And I cancel the introductory video on the devices
Then I take a screenshot in the first device
Then I take a screenshot in the second device

