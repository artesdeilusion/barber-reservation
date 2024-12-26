import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CheckReservation extends StatefulWidget {
  const CheckReservation({super.key});

  @override
  State<CheckReservation> createState() => _CheckReservationState();
}

class _CheckReservationState extends State<CheckReservation> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false; // Loading state

  Future<void> _searchReservation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('code', isEqualTo: _codeController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final reservationData = querySnapshot.docs.first.data();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReservationDetailsPage(
              reservationData: reservationData,
            ),
          ),
        );
      } else {
        _showMessage("Randevu bulunamadı");
      }
    } catch (e) {
      _showMessage("Hata oluştu: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Randevu Sorgula"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
TextField(
      controller: _codeController,
      decoration: InputDecoration(
        labelText: "Randevu Kodu",
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.paste),
          onPressed: () async {
            // Get the data from the clipboard
            ClipboardData? data = await Clipboard.getData('text/plain');
            if (data != null) {
              // Paste the clipboard data into the text field
              setState(() {
                _codeController.text = data.text!;
              });
            }
          },
        ),
                  )),            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchReservation,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Sorgula"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
 
class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  const ReservationDetailsPage({super.key, required this.reservationData});

  @override
  Widget build(BuildContext context) {
    final bool isActive = reservationData['active'] ?? true;
    final String reason = reservationData['reason'] ?? "";
    final String maskedPhone = _maskPhoneNumber(reservationData['phone']);
    final DateTime date = (reservationData['date'] as Timestamp).toDate();
    final DateTime startTime = (reservationData['startTime'] as Timestamp).toDate();
    final DateTime endTime = (reservationData['endTime'] as Timestamp).toDate();
    final String maskedName = _maskName(reservationData['name']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Randevu Detayları"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          color: isActive ? Colors.white : Colors.red[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Randevu Detayları:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildDetailRow("Ad Soyad:", maskedName),
                _buildDivider(),
                _buildDetailRow("Telefon:", maskedPhone),
                _buildDivider(),
                _buildDetailRow("Berber:", reservationData['barber']),
                _buildDivider(),
                const Text(
                  "Hizmetler:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...(reservationData['services'] as List)
                    .map((service) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text("∙ $service"),
                        )),
                const SizedBox(height: 10),
                _buildDivider(),
                _buildDetailRow("Tarih:", DateFormat.yMMMd().format(date)),
                _buildDivider(),
                _buildDetailRow("Başlangıç Saati:", DateFormat.jm().format(startTime)),
                _buildDivider(),
                _buildDetailRow("Bitiş Saati:", DateFormat.jm().format(endTime)),
                _buildDivider(),
                _buildDetailRow("Kod:", reservationData['code']),
                const SizedBox(height: 10),
                if (!isActive) ...[
                  const Text(
                    "Randevu İptal Nedeni:",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  Text(reason),
                ],
                if (isActive) ...[
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showDeleteDialog(context),
                    child: const Text("Randevuyu Sil"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _maskName(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      String firstName = nameParts[0];
      String lastName = nameParts[1];
      return '${firstName[0]}${'*' * (firstName.length - 1)} ${lastName[0]}${'*' * (lastName.length - 1)}';
    } else {
      return name[0] + '*' * (name.length - 1);
    }
  }

  String _maskPhoneNumber(String phone) {
    return phone.replaceRange(3, phone.length - 2, '*' * (phone.length - 5));
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(thickness: 1, color: Colors.grey);
  }

  void _showDeleteDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Telefon Numarası Doğrulama"),
          content: TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: "555 555 55 55",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeReservation(phoneController.text.trim(), context);
              },
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }
Future<void> _removeReservation(String phone, BuildContext context) async {
  if ("+90$phone" == reservationData['phone']) {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(reservationData['code'])
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Randevu başarıyla silindi")),
      );
      Navigator.of(context).pop(); // Close the details page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Randevu silinirken hata oluştu: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Telefon numarası eşleşmiyor")),
    );
  }
}
}