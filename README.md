# GreenBike
Salt Lake City's unofficial bike share app. 

Three main screens that use different Swift technologies:

1. Map
MapKit & Location Manager
- Able to locate user & all SLC bike share docks. Able to fly in on the entire map of SLC bikes or the user's current location and his/her three closest stations.

2. Table View
TableView, Custom Cells, & Code-based Constraints
- Custom cells show the number of bikes & docks, the address of all bike stations, the distance and cardinal direction from the user. Gesture recognizers allow users to favorite bike stations and save them using an array of strings in User Defaults. Code-based Constraints are called to make the cells update whether the user has location services enabled.

3. Alerts
TableView, Custom Cells, & Local Notifications
- Custom cells show all alerts that the user has created with optional fromBikeStation, toBikeStation, and days on which the alert will repeat.  Local Notifications present an alert to the user at the set time.

Other Skills:
Web APIs, Codable, Notification Center, 
- Use the BikeSharing API (https://citybik.es) to get data from the web and show user. Codable to save the load alerts from local storage using .plist file that gets created in code. Notification Center to alert various view controllers when location gets updated.
