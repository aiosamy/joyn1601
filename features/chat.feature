Feature: Chat Feature

Scenario: As a valid user I can chat with my joyn contact
Given joyn app is running on the first device
When I see the contact 'Lake' in joyn contacts list of the first device
Then I cleanup the chat history for the contact 'Lake' in the first device
Then I take a screenshot in the first device

And also in Second Device joyn app is running
When I see the contact 'Beach' in joyn contacts list of the second device
Then I cleanup the chat history for the contact 'Beach' in the second device
Then I take a screenshot in the second device
Then I put the Joyn app in background in the second device
Then I take a screenshot in the second device


Then I send a chat message 'first joyn chat message' to the contact 'Lake'
Then I take a screenshot in the first device

When I wait to see the Joyn Chat Notification message in the second device
Then I take a screenshot in the second device
Then I should see the message delivery status in the first device as Successful
Then I take a screenshot in the first device

When I open the notification message from contact 'Beach' to read the chat message in the second device
Then I should see the message 'first joyn chat message' in the second device
Then I send 'first joyn chat message ack' as a response in the second device
Then I take a screenshot in the second device

Then I wait to see message 'first joyn chat message ack' in the first device
Then I take a screenshot in the first device
Then I should see the message delivery status in the second device as Successful
Then I take a screenshot in the second device
