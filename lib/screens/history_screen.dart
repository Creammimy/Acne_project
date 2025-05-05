import 'package:flutter/material.dart';
import 'package:project_acne_scan/screens/graph_screen.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mockData = [
    {
      'analysis_date': '2025-02-10',
      'total_acne_count': 5,
    },
    {
      'analysis_date': '2025-02-09',
      'total_acne_count': 3,
    },
    {
      'analysis_date': '2025-02-08',
      'total_acne_count': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ประวัติการวิเคราะห์ย้อนหลัง"),
        backgroundColor: Color(0xFFCDF8F7),
      ),
      body: Column(
        children: [
          // ลิงก์ไปที่หน้า GraphScreen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GraphScreen(), // ไปที่หน้ากราฟ
                  ),
                );
              },
              child: Text('ดูกราฟพัฒนาการ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCDF8F7),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockData.length,
              itemBuilder: (context, index) {
                var data = mockData[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.network(
                        'https://via.placeholder.com/80', // ใช้ URL ภาพจำลอง
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text("วันที่: ${data['analysis_date']}"),
                    subtitle: Text("จำนวนสิวทั้งหมด: ${data['total_acne_count']} จุด"),
                    onTap: () {
                      // ไปที่หน้ารายละเอียด
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(data: data),
                        ),
                      );
                    },
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

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  DetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดการวิเคราะห์"),
        backgroundColor: Color(0xFFCDF8F7),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(data['image_url'], width: 200, height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text("วันที่: ${data['analysis_date']}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text("จำนวนสิวทั้งหมด: ${data['total_acne_count']} จุด", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text("รายละเอียดเพิ่มเติม...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
