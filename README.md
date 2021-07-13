# UberAPPTest

This APP made programmatically and contains: 

- MVVM 
- Alamofire for RestApi (login and register)
- Mapkit for creating mapviews
- KeychainAccess for taking token
- Core location for getting users' current location and update driver location
- Socket.io for getting realtime connection between driver and client while ordering
- Note: Backend and server for socket.io is created by ME. I used Node.js and Express.js while creating backend.   

1. Onboarding screen which takes you to auth screen

![ezgif-4-a8358cb46586](https://user-images.githubusercontent.com/47345666/125296635-89d3d600-e337-11eb-86f7-7fd2aa578b4d.gif)

2. Realtime connection between User(left screen view) and Dirver(right screen view). User can select a location and add locationmark by touching on the screen or by searching the name of region. When user made an order with user's and destination's location, driver get the order on screen at the moment. Then driver get navigation to user location at first and when driver reaches the user's location, new navigation to destination location from user's location is created by app.

![ezgif-4-a3d56ec344a5](https://user-images.githubusercontent.com/47345666/125297160-0e265900-e338-11eb-905d-61c2012536df.gif)
