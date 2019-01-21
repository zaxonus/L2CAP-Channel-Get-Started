# L2CAP-Channel-Get-Started
A simple example of making something working with CoreBluetooth L2CAP Channel.

This project is released as an example of using L2CAP channel to communicate between two iOS devices. It took me a bit of time and research to make that work, I hope it will help some other people facing the same challenge.

The project has two targets, one is the peripheral app and the other one is the central app. The user interface for both apps is very similar. For that reason I have created a class called L2CAPC_ViewController containing the bulk of the code common to both apps. Then the classes for both apps L2C_Peripheral_ViewController and L2C_Central_ViewController all inherits from L2CAPC_ViewController.

The flow of the data transmitted can go both ways from the peripheral to the central and vice-versa. Each app has a button "Send Randon String"; when it is tapped, a Randon String is generated on the device and then transmitted to the other device via L2CAP channel.

To try, install the peripheral on one device and the central on another one.
