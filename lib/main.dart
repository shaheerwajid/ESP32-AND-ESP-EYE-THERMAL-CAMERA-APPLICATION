import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class LEOSController extends StatefulWidget {
  @override
  _LEOSControllerState createState() => _LEOSControllerState();
}

class _LEOSControllerState extends State<LEOSController> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;
  bool isScanning = false;
  String connectionStatus = "Disconnected";
  String lastPacketSent = "No packet sent yet";

  bool showScanResults = false;
  bool showCameraControls = false;
  bool showPolarityControls = false;

  List<int> dataPacket = List<int>.filled(16, 0);
  StreamSubscription<List<ScanResult>>? scanSubscription;
  final Set<String> _pressedButtons = {};

  final Map<String, List<Map<String, dynamic>>> controlGroups = {
    'Camera': [
      {
        'name': 'Normal/White Mode',
        'packet': [161, 55, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 236],
        'icon': Icons.wb_sunny,
        'color': Colors.blueGrey,
      },
      {
        'name': 'Detail Mode',
        'packet': [161, 55, 1, 244, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 14],
        'icon': Icons.zoom_in,
        'color': Colors.blue,
      },
      {
        'name': 'Brightness 25%',
        'packet': [161, 85, 20, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 240],
        'icon': Icons.brightness_low,
        'color': Colors.amber[300]!,
      },
      {
        'name': 'Brightness 50%',
        'packet': [161, 85, 196, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 189, 136],
        'icon': Icons.brightness_medium,
        'color': Colors.amber,
      },
      {
        'name': 'Brightness 75%',
        'packet': [161, 85, 16, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 217, 80],
        'icon': Icons.brightness_high,
        'color': Colors.amber[700]!,
      },
    ],
    'Polarity': [
      {
        'name': 'White Hot',
        'packet': [161, 111, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 79],
        'icon': Icons.wb_sunny,
        'color': Colors.blueGrey,
      },
      {
        'name': 'Rainbow',
        'packet': [161, 111, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 208],
        'icon': Icons.filter_vintage,
        'color': Colors.pink,
      },
      {
        'name': 'Sepia',
        'packet': [161, 111, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 165],
        'icon': Icons.filter_b_and_w,
        'color': Colors.brown,
      },
      {
        'name': 'Blackhot Fire',
        'packet': [161, 111, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 238],
        'icon': Icons.fireplace,
        'color': Colors.deepOrange,
      },
      {
        'name': 'Iron',
        'packet': [161, 111, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 155],
        'icon': Icons.settings,
        'color': Colors.grey,
      },
      {
        'name': 'Ironbow',
        'packet': [161, 111, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 4],
        'icon': Icons.color_lens,
        'color': Colors.purple,
      },
      {
        'name': 'Blackhot',
        'packet': [161, 111, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 113],
        'icon': Icons.nights_stay,
        'color': Colors.black,
      },
      {
        'name': 'Hot Iron',
        'packet': [161, 111, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 146],
        'icon': Icons.whatshot,
        'color': Colors.red,
      },
      {
        'name': 'White Hot Fire',
        'packet': [161, 111, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 231],
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    requestPermissions();
    dataPacket[0] = 161;
    dataPacket[1] = 111;
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }

  bool _isButtonPressed(String buttonName) => _pressedButtons.contains(buttonName);

  void _setButtonPressed(String buttonName, bool pressed) {
    setState(() {
      if (pressed) {
        _pressedButtons.add(buttonName);
      } else {
        _pressedButtons.remove(buttonName);
      }
    });
  }

  Color _darkenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Future<void> requestPermissions() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
  }

  Future<void> startScan() async {
    if (await Permission.bluetoothScan.isGranted) {
      setState(() {
        isScanning = true;
        devices.clear();
        connectionStatus = "Scanning...";
        showScanResults = true;
        showCameraControls = false;
        showPolarityControls = false;
      });

      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          devices = results.map((r) => r.device).toList();
        });
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } else {
      await requestPermissions();
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    scanSubscription?.cancel();
    setState(() {
      isScanning = false;
      connectionStatus = connectedDevice == null ? "Disconnected" : "Connected";
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() => connectionStatus = "Connecting...");
    try {
      await device.connect(autoConnect: false);
      setState(() {
        connectedDevice = device;
        connectionStatus = "Discovering services...";
        showScanResults = false;
      });

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            setState(() {
              targetCharacteristic = characteristic;
              connectionStatus = "Connected to ${device.name}";
            });

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully connected to ${device.name}'),
                  duration: Duration(seconds: 2),
                )
            );
            return;
          }
        }
      }
      setState(() => connectionStatus = "No writable characteristic found");
    } catch (e) {
      setState(() => connectionStatus = "Connection failed: ${e.toString()}");
    }
  }

  Future<void> sendPacket(List<int> packet) async {
    if (connectedDevice == null || targetCharacteristic == null) {
      setState(() => connectionStatus = "Error: Not connected");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please connect to a device first'))
      );
      return;
    }

    try {
      await targetCharacteristic!.write(packet);
      setState(() {
        connectionStatus = "Connected to ${connectedDevice!.name}";
        lastPacketSent = "Sent: ${packet.join(' ')}";
      });
    } catch (e) {
      setState(() => connectionStatus = "Error sending packet: ${e.toString()}");
    }
  }

  Widget _buildControlButton(Map<String, dynamic> config) {
    return GestureDetector(
      onTap: () => sendPacket(List<int>.from(config['packet'])),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: 120,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isButtonPressed(config['name'])
              ? _darkenColor(config['color'], 0.2)
              : config['color'],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        transform: Matrix4.identity()..scale(_isButtonPressed(config['name']) ? 0.95 : 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config['icon'], size: 30, color: Colors.white),
            SizedBox(height: 8),
            Text(
              config['name'],
              style: TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      onTapDown: (_) => _setButtonPressed(config['name'], true),
      onTapUp: (_) => _setButtonPressed(config['name'], false),
      onTapCancel: () => _setButtonPressed(config['name'], false),
    );
  }

  Widget _buildDeviceList() {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Scanning for devices..."),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text(devices[index].name.isEmpty
                ? "Unknown Device"
                : devices[index].name),
            subtitle: Text(devices[index].id.toString()),
            trailing: IconButton(
              icon: Icon(Icons.link),
              onPressed: () => connectToDevice(devices[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentSection() {
    if (showScanResults) {
      return _buildDeviceList();
    } else if (showCameraControls) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: controlGroups['Camera']!.map((button) =>
            _buildControlButton(button)
        ).toList(),
      );
    } else if (showPolarityControls) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: controlGroups['Polarity']!.map((button) =>
            _buildControlButton(button)
        ).toList(),
      );
    } else {
      return Center(
        child: Text(
          'Select an option above',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/LEOS.png',
              height: 40,
            ),
            SizedBox(height: 2),
            Text(
              'powered by TeamAI',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  connectionStatus,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isScanning ? stopScan : startScan,
                  child: Text(isScanning ? 'Stop Scan' : 'Scan'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                ),
                ElevatedButton(
                  onPressed: connectedDevice == null ? null : () {
                    setState(() {
                      showCameraControls = !showCameraControls;
                      showPolarityControls = false;
                      showScanResults = false;
                    });
                  },
                  child: Text('Camera Controller'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: connectedDevice == null ? null : () {
                    setState(() {
                      showPolarityControls = !showPolarityControls;
                      showCameraControls = false;
                      showScanResults = false;
                    });
                  },
                  child: Text('Polarity Controller'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _buildContentSection(),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Packet Sent:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    SelectableText(
                      lastPacketSent,
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}