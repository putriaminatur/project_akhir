import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  List<dynamic> _holidays = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year; // Zona waktu default

  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchHolidays();
  }

  Future<void> _fetchHolidays() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://myopentrip.com/api/public-holiday?year=$_selectedYear'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _holidays = data;
          _isLoading = false;
        });
      } else {
        logger.e('Error: Status code ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error fetching holidays: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeYear(int year) {
    setState(() {
      _selectedYear = year;
    });
    _fetchHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hari Libur Nasional dan Hari Penting $_selectedYear',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bagian Tahun
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (_selectedYear > 2000) {
                      _changeYear(_selectedYear - 1);
                    }
                  },
                  icon: const Icon(Icons.arrow_left),
                ),
                Text(
                  'Tahun $_selectedYear',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    _changeYear(_selectedYear + 1);
                  },
                  icon: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),

          // Daftar Hari Libur
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _holidays.isEmpty
                    ? Center(
                        child: Text(
                          'Data tidak tersedia untuk tahun ini',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _holidays.length,
                        itemBuilder: (context, index) {
                          final holiday = _holidays[index];
                          final date = holiday['date'] ?? 'Tanggal tidak diketahui';
                          final summary =
                              holiday['summary'] ?? 'Tidak ada deskripsi';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Colors.teal),
                              title: Text(
                                date,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                summary,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
