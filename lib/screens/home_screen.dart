import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan untuk logout
import 'holiday_screen.dart';
import 'profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Daftar halaman untuk navigasi
  final List<Widget> _pages = [
    const HomePage(),
    const HolidayScreen(),
    const ProfileScreen(),
  ];

  // Fungsi logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser'); // Hapus sesi login
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login'); // Navigasi ke login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aplikasi Hari Libur',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _logout(context), // Fungsi logout
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex], // Halaman yang ditampilkan
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Halaman aktif
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Ganti halaman
          });
        },
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.teal.shade100,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Holidays',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String time = '';
  String location = '';
  Timer? timer;

  @override
  void initState() {
    super.initState();
    getTime(); // Ambil waktu saat pertama kali dibuka
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime()); // Perbarui setiap detik
  }

  Future<void> getTime() async {
  try {
    final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Jakarta'));
    Map data = jsonDecode(response.body);

    String datetime = data['datetime'];
    String offset = data['utc_offset']; // Contoh: "+07:00"

    // Konversi offset ke integer dalam jam dan menit
    final offsetHours = int.parse(offset.substring(1, 3));
    final offsetMinutes = int.parse(offset.substring(4, 6));

    // Parse waktu UTC dan tambahkan offset
    DateTime now = DateTime.parse(datetime);
    if (offset.startsWith('+')) {
      now = now.add(Duration(hours: offsetHours, minutes: offsetMinutes));
    } else {
      now = now.subtract(Duration(hours: offsetHours, minutes: offsetMinutes));
    }

    setState(() {
      time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      location = data['timezone'];
    });
  } catch (e) {
    print('Error fetching time data: $e');
    setState(() {
      time = 'Could not get time data';
      location = '';
    });
  }
}


  void updateTime() {
    if (time.isNotEmpty) {
      final parts = time.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      seconds++;
      if (seconds == 60) {
        seconds = 0;
        minutes++;
      }
      if (minutes == 60) {
        minutes = 0;
        hours++;
      }
      
      // Jika jam lebih dari atau sama dengan 24, reset ke jam awal.
      if (hours >= 24) {
        hours = hours % 24;
      }
      
      setState(() {
        time = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Hentikan timer saat widget dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 100, color: Colors.teal),
          const SizedBox(height: 20),
          Text(
            'Waktu saat ini di $location',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            time.isNotEmpty ? time : 'Loading...',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

