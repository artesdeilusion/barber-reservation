import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
 import 'package:intl_phone_field/intl_phone_field.dart';
 
 class CreateReservation extends StatefulWidget {
  const CreateReservation({super.key});

  @override
  State<CreateReservation> createState() => _CreateReservationState();
}
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
 
class _CreateReservationState extends State<CreateReservation> {
  @override
   final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

var currentPage = 0;
  // Kullanıcı Verileri
  String name = '';
  String phoneNumber = '';
  String selectedBarber = '';
  String selectedBarberId = ' ';
  List<String> selectedServices = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  num totalMinutes = 0;
  String reservationCode ="";
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
leading: 

currentPage == 6 ? null :
       currentPage == 0  
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              icon: const Icon(Icons.arrow_back)
            )
          : IconButton(
              onPressed: _previousPage, 
              icon: const Icon(Icons.arrow_back)
            )
     ,
  title: Text(
    currentPage == 0
        ? "Bilgilerinizi Girin"
        : currentPage == 1
            ? "Berberinizi Seçin"
            : currentPage == 2
                ? "Hizmetlerinizi Seçin"
                : currentPage == 3
                ? "Tarih Seçin"
                : currentPage == 4
                ? "Saat Seçin"
                : currentPage == 5
                ? "Randevu Özeti"
                : "Randevunuz Oluşturuldu"
            )      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
          });
        },
        physics: const NeverScrollableScrollPhysics(), // Manuel geçiş
        children: [
          _buildPersonalInfoPage(),
          _buildBarberSelectionPage(),
           _buildServiceSelectionPage(),
           _buildDateSelectionPage(),
           _buildTimeSelectionPage(),
          _buildReviewPage(),
          _buildConfirmationPage(),
        ],
      ),
    );
  }

  // Sayfa geçiş fonksiyonu
  void _nextPage() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
 
   bool isCheckboxChecked = false;


  Widget _buildPersonalInfoPage() {
    return Form(
      key: _formKey1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Lütfen isim, soyisim ve telefon bilginizi girin. Bu bilgiler randevu oluşturmak için gereklidir.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "İsim - Soyisim",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(224, 224, 224, 1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(224, 224, 224, 1),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Bu alan boş bırakılamaz";
                }
                return null;
              },
              onSaved: (value) => name = value!,
            ),
            const SizedBox(height: 10),
            IntlPhoneField(
              languageCode: "tr",
              searchText: "Ülke Ara",
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(224, 224, 224, 1),
                  ),
                ),
              ),
              initialCountryCode: 'TR',
              onChanged: (phone) {
                setState(() {
                  phoneNumber = phone.completeNumber;
                });
              },
              validator: (phone) {
                if (phone == null || phone.completeNumber.isEmpty) {
                  return 'Telefon Numarası giriniz';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Restrict input to digits only
              ],
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Kişisel bilgilerimin kullanılmasını kabul ediyorum."),
              value: isCheckboxChecked,
              onChanged: (bool? value) {
                setState(() {
                  isCheckboxChecked = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isCheckboxChecked
                      ? () {
                          // Validate the form
                          if (_formKey1.currentState!.validate()) {
                            // Save the form fields
                            _formKey1.currentState!.save();
                            // Check if the phone number is not empty
                            if (phoneNumber.isNotEmpty) {
                              // Proceed to the next page
                              _nextPage();
                            } else {
                              // Show an error message if the phone number is empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Telefon Numarası giriniz')),
                              );
                            }
                          }
                        }
                      : (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Onay kutusunu işaretleyin.")),
                          );
                        }, // Disable the button if the checkbox is not checked
                  child: const Text("Devam Et"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
 
}   
    Widget _buildBarberSelectionPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('barbers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final barbers = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               
              Expanded(
                child: ListView.builder(
                  itemCount: barbers.length,
                  itemBuilder: (context, index) {
                    final barber = barbers[index];
                    return RadioListTile(
                      contentPadding:EdgeInsets.zero,
                      title: Text(barber['name']),
                      value: barber['name'],
                        groupValue: selectedBarber,
                        onChanged: (value) {
                          setState(() {
                            selectedBarber = value!;
selectedBarberId = barber["id"];
                          });
                        },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: selectedBarber.isNotEmpty
                        ? _nextPage
                        : null, // Seçilmeden geçilemez
                    child: const Text("Devam Et"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

    Widget _buildServiceSelectionPage() {
    final services = {
      "Saç Kesimi + Yıkama": 30,
      "Sakal Kesimi": 5,
      "Saç Yıkama": 5,
      "Kulak Yanak Ağda": 5,
      "Ense Tıraşı": 5,
      "Saç Renklendirme": 5,
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Expanded(
            child: ListView(
              children: services.keys.map((service) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(service),
                  subtitle: Text("${services[service]} dakika"),
                  value: selectedServices.contains(service),
                  onChanged: (bool? selected) {
                    setState(() {
                     setState(() {
  if (selected == true) {
    selectedServices.add(service);
    totalMinutes += services[service]!;
  } else {
    selectedServices.remove(service);
    totalMinutes -= services[service]!;
  }
});

                    });
                  },
                );
              }).toList(),
            ),
          ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: selectedServices.isNotEmpty ? _nextPage : null,
                child: const Text("Devam Et"),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildDateSelectionPage() {
  final DateTime now = DateTime.now();
  final DateTime tomorrow = now.add(Duration(days: 1));

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('barbers')
        .doc(selectedBarberId)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
        return const Center(
          child: Text(
            'Veri çekme hatası veya berber bulunamadı',
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      final barberData = snapshot.data!.data() as Map<String, dynamic>;
      final closedDaysTimestamps = List.from(barberData['closedDays'] ?? []);
      final List<DateTime> closedDays = closedDaysTimestamps
          .map((timestamp) => (timestamp as Timestamp).toDate())
          .toList();

      final List<DateTime> availableDates = [now, tomorrow].where((date) {
        return !closedDays.any((closedDate) =>
            date.year == closedDate.year &&
            date.month == closedDate.month &&
            date.day == closedDate.day);
      }).toList();

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            Expanded(
              child: availableDates.isEmpty
                  ? const Center(
                      child: Text(
                        'Mevcut tarih yok',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: availableDates.length,
                      itemBuilder: (context, index) {
                        final date = availableDates[index];
                        final formattedDate = DateFormat('d MMMM EEEE', 'tr_TR').format(date);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(formattedDate),
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                            _nextPage();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTimeSelectionPage() {
  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance
        .collection('appointments')
        .where('barberCode', isEqualTo: selectedBarberId)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || !snapshot.hasData) {
        return const Center(child: Text("Bir hata oluştu. Lütfen tekrar deneyin."));
      }

      // Parse appointments from Firebase
      final List<Appointment> appointments = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final DateTime startTime = (data['startTime'] as Timestamp).toDate();
        final DateTime endTime = (data['endTime'] as Timestamp).toDate();
  // Format the start and end times in Turkish hour style
  String formattedStartTime = DateFormat('HH:mm', 'tr_TR').format(startTime);
  String formattedEndTime = DateFormat('HH:mm', 'tr_TR').format(endTime);

  // Include the formatted times in the subject
    String subject = '($formattedStartTime - $formattedEndTime)';

        return Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: subject,
          isAllDay: false,
        );
      }).toList();

      return _buildTimetable(appointments);
    },
  );
}
Widget _buildTimetable(List<Appointment> appointments) {
  final isSaturday = selectedDate?.weekday == DateTime.saturday;
  final startHour = isSaturday ? 10 : 10; // Start at 10 AM for all days
  final endHour = isSaturday ? 15 : 18; // End at 3 PM on Saturdays, 6 PM on weekdays

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      
      Expanded(
        child: SfCalendar(
          viewNavigationMode: ViewNavigationMode.none,
           showNavigationArrow: false,
          view: CalendarView.day,
          initialDisplayDate: selectedDate,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: startHour.toDouble(),
            endHour: endHour.toDouble(),
            timeInterval: const Duration(minutes: 30),
          ),
          dataSource: AppointmentDataSource(appointments),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => _selectTime(appointments),
              child: const Text("Saat Seç"),
            ),
          ],
        ),
      ),
    ],
  );
}
Future<void> _selectTime(List<Appointment> appointments) async {
  final isSaturday = selectedDate?.weekday == DateTime.saturday;
  const startAllowed = TimeOfDay(hour: 10, minute: 0);
  final endAllowed = isSaturday
      ? const TimeOfDay(hour: 15, minute: 0)
      : const TimeOfDay(hour: 18, minute: 0);

  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 10, minute: 0),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );

  if (pickedTime != null) {
    final selectedStart = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final selectedEnd = selectedStart.add(Duration(minutes: totalMinutes.toInt()));

    // Convert allowed end time to DateTime
    final allowedEndTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endAllowed.hour,
      endAllowed.minute,
    );

    // Check if the selected time is within allowed hours
    if (pickedTime.hour < startAllowed.hour ||
        (pickedTime.hour == startAllowed.hour && pickedTime.minute < startAllowed.minute) ||
        pickedTime.hour > endAllowed.hour ||
        (pickedTime.hour == endAllowed.hour && pickedTime.minute > endAllowed.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seçilen saat çalışma saatleri dışında.")),
      );
      return;
    }

    // Check if the selected end time exceeds allowed working hours
    if (selectedEnd.isAfter(allowedEndTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seçtiğiniz süre çalışma saatlerini aşıyor.")),
      );
      return;
    }

    // Check for overlap with existing appointments
    final bool isOverlapping = appointments.any((appointment) {
      return selectedEnd.isAfter(appointment.startTime) && 
             selectedStart.isBefore(appointment.endTime);
    });

    if (isOverlapping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seçtiğiniz saat mevcut bir randevuya denk geliyor.")),
      );
    } else {
      setState(() {
        selectedTime = pickedTime;
      });

      // Proceed to the next step
      _nextPage();
    }
  }
}

Widget _buildReviewPage() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Randevu Detayları",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildDetailRow("İsim:", name.isNotEmpty ? name : "-"),
              _buildDivider(),
              _buildDetailRow("Telefon:", phoneNumber.isNotEmpty ? phoneNumber : "-"),
              _buildDivider(),
              _buildDetailRow("Berber:", selectedBarber.isNotEmpty ? selectedBarber : "-"),
              _buildDivider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hizmetler:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...selectedServices.map((service) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "∙ $service",
                          style: const TextStyle(fontSize: 16),
                        ),
                      )),
                ],
              ),
              _buildDivider(),
              _buildDetailRow(
                "Tarih:",
                selectedDate != null ? DateFormat.yMMMd('tr_TR').format(selectedDate!) : "-",
              ),
              _buildDivider(),
              _buildDetailRow(
                "Başlangıç Saati:",
                selectedTime != null
                    ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                    : "-",
              ),
              _buildDivider(),
              _buildDetailRow(
                "Bitiş Saati:",
                selectedDate != null && selectedTime != null
                    ? "${(selectedTime!.hour + (selectedTime!.minute + totalMinutes) ~/ 60).toString().padLeft(2, '0')}:${((selectedTime!.minute + totalMinutes) % 60).toString().padLeft(2, '0')}"
                    : "-",
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final String uniqueCode = _generateUniqueCode();
                      FirebaseFirestore.instance.collection('appointments').add({
                        'name': name,
                        'phone': phoneNumber,
                        'barber': selectedBarber,
                        'services': selectedServices,
                        'date': Timestamp.fromDate(selectedDate!),
                        'startTime': Timestamp.fromDate(
                          DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          ),
                        ),
                        'endTime': Timestamp.fromDate(
                          DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          ).add(Duration(minutes: totalMinutes.toInt())),
                        ),
                        'code': uniqueCode,
                        'barberCode': selectedBarberId,
                        'active': true,
                        'reason': '',
                      });

                      setState(() {
                        reservationCode = uniqueCode;
                      });
                      _nextPage();
                    },
                    child: const Text("Onayla ve Randevu Al"),
                    style: ElevatedButton.styleFrom(
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

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


  String _generateUniqueCode() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(6);
  }



  Widget _buildConfirmationPage() {
 
    return Center(
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                "Randevunuz Oluşturuldu!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Randevu Kodunuz:",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              SelectableText(
                reservationCode,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FloatingActionButton.extended(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: reservationCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Kod kopyalandı")),
                  );
                },
                icon: Icon(Icons.copy),
                label: Text("Kodunuzu Kopyalayın"),
 
              ),
              const SizedBox(height: 20),
              FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    selectedServices.clear(); // Seçilen hizmetleri temizle
                    selectedDate = null; // Seçilen tarihi sıfırla
                    selectedTime = null; // Seçilen saati sıfırla
                    totalMinutes = 0; // Toplam dakikayı sıfırla
                    reservationCode = ''; // Rezervasyon kodunu temizle
                  });
                  Navigator.pop(context); // Ana sayfaya geri dön
                },
                icon: Icon(Icons.home),
                label: Text("Ana Sayfaya Dön"),
               ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  }