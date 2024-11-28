import 'package:flutter/material.dart';
import 'screens/food_crud_screen.dart';
import 'screens/order_plan_screen.dart';
import 'screens/saved_orders_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App', // The App title for the app icon and minimized state
      theme: ThemeData(
        primarySwatch: Colors.orange,
        appBarTheme: const AppBarTheme(
          color: Color(0xFF2C2C2C),  // Dark muted gray for modern look
          elevation: 4,  // Subtle shadow effect
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,  // White title for better contrast
          ),
          iconTheme: IconThemeData(color: Colors.white),  // White icons
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF333333),  // Dark background for bottom nav
          selectedItemColor: Colors.orange,  // Highlight color for selected icon
          unselectedItemColor: Colors.white,  // Muted icons for unselected
        ),
      ),
      home: const BottomNavScreen(), // Default home screen
    );
  }
}

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({Key? key}) : super(key: key);

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const FoodCRUDScreen(),
    const SavedOrdersScreen(),
    const OrderPlanScreen(),
  ];

  // Update the current screen when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Manage Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Saved Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create Order',
          ),
        ],
      ),
    );
  }
}
