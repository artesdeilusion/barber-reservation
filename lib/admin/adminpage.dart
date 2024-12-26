import 'dart:html' as html;
import 'package:barber_reservation/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}



class _AdminPageState extends State<AdminPage> {
  String? _selectedBarberId;
  String? _selectedBarberName;
  int _selectedIndex = 0;
  bool _isLoading = false;
  List<DateTime> _closedDays = [];
  DateTime? _selectedDate;
  List<Appointment> _appointments = [];
 

Future<String?> _checkAdminRole() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    
    if (userDoc.exists) {
      return userDoc.get('role') as String?;
    }
    return null;
  } catch (e) {
    print('Error checking admin role: $e');
    return null;
  }
}  @override
  void initState() {
    super.initState();
    _loadInitialBarber();
  }

  void _loadInitialBarber() async {
    // Load the initial barber (if any) here
    setState(() {
      _selectedBarberId = null;
      _selectedBarberName = null;
    });
  }

  Future<void> _showSignOutConfirmation() async {
    bool? confirmSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış'),
          content: const Text('Çıkmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false (not confirmed)
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true (confirmed)
              },
              child: const Text('Çıkış'),
            ),
          ],
        );
      },
    );

    if (confirmSignOut == true) {
      AuthService().signOut(); // Proceed with sign-out
    }
  }

  Future<void> _loadClosedDays() async {
    if (_selectedBarberId == null) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('barbers')
          .doc(_selectedBarberId)
          .get();
      final List<dynamic> closedDays = doc['closedDays'];
      setState(() {
        _closedDays = closedDays.map((timestamp) => (timestamp as Timestamp).toDate()).toList();
      });
    } catch (e) {
      _showMessage('Hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    if (_selectedBarberId == null) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('barberCode', isEqualTo: _selectedBarberId)
          .get();
      final appointments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Appointment(
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
          subject: data['name'] ?? 'Randevu',
          color: Colors.green,

          notes: data['phone'], // Store document ID in notes for deletion
        );
      }).toList();
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      _showMessage('Hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addAppointment(DateTime startTime, DateTime endTime) async {
    if (_selectedBarberId == null) return;
    final newAppointment = Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: 'Dolu Saat',
      color: Colors.black,
    );
    setState(() {
      _appointments.add(newAppointment);
    });
    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'barberCode': _selectedBarberId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'name': newAppointment.subject,
        "date":Timestamp.fromDate(startTime),
      });
      _showMessage('Randevu eklendi.');
    } catch (e) {
      _showMessage('Randevu eklenirken hata oluştu: $e');
    }
  }

  Future<void> _removeAppointment(Appointment appointment) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.notes)
          .delete();
      setState(() {
        _appointments.remove(appointment);
      });
      _showMessage('Randevu silindi.');
    } catch (e) {
      _showMessage('Randevu silinirken hata oluştu: $e');
    }
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
    floatingActionButton: FloatingActionButton.extended(
  icon: const Icon(Icons.add),
  onPressed: () async {
    if (_selectedIndex == 0) {
      // Page 0: Show Add Appointment Dialog
      _showAddAppointmentDialog(DateTime.now());
    } else if (_selectedIndex == 1) {
      // Page 1: Show Add Barber Dialog
      _showAddBarberDialog();
    } else if (_selectedIndex == 2) {
  DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
            });
            await _addClosedDay();
          }  }
  }, label:  _selectedIndex == 0 ? const Text("Randevu Ekle") : _selectedIndex == 1 ? const Text("Berber Ekle") : const Text("Kapalı Gün Ekle"),
     
),
       body: !isMobile ? Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              _navigateToScreen(index);
            },
            labelType: NavigationRailLabelType.all,
            trailing: IconButton(onPressed:_showSignOutConfirmation, icon: const Icon(Icons.logout)),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Takvim'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.content_cut),
                selectedIcon: Icon(Icons.content_cut),
                label: Text('Berberler'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_view_day_sharp),
                selectedIcon: Icon(Icons.calendar_view_day_sharp),
                label: Text('Kapalı Günler'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 0.5, width: 0.5),
Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),)
        ],
      ):_isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),

      bottomNavigationBar: isMobile
          ? NavigationBar(
            selectedIndex: _selectedIndex,
               onDestinationSelected:  (int index) {
                _navigateToScreen(index);
              },
              
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today),
                  label: 'Takvim',
                ),
                NavigationDestination(
                  icon: Icon(Icons.content_cut),
                  label: 'Berberler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_view_day_sharp),
                  label: 'Kapalı Günler',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildCalendarView();
      case 1:
        return _buildBarberSelection();
      case 2:
        return _buildSettings();
      default:
        return _buildBarberSelection();
    }
  }

  Widget _buildCalendarView() {
            final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        AppBar(
automaticallyImplyLeading: false,
centerTitle: false,
        title: const Text("Takvim"),
        actions: [StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('barbers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return DropdownButton<String>(
                            underline: const SizedBox(),

              hint: Text(_selectedBarberName ?? "Berber Seç"),
              value: _selectedBarberId,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBarberId = newValue;
                  _selectedBarberName = null;
                  _loadClosedDays();
                  _loadAppointments();
                });
                FirebaseFirestore.instance.collection('barbers').doc(newValue).get().then((doc) {
                  setState(() {
                    _selectedBarberName = doc['name'];
                  });
                });
              },
              items: snapshot.data!.docs.map((DocumentSnapshot document) {
                return DropdownMenuItem<String>(
                  value: document.id,
                  child: Text(document.get('name')),
                );
              }).toList(),
            );
          },
        ),
        ...isMobile ? [
          const SizedBox(width: 5,),IconButton(onPressed:_showSignOutConfirmation, icon: const Icon(Icons.logout),),const SizedBox(width: 5,)
        ] : [Container()],

        ]
      ),
        Expanded(
          child: SfCalendar(
                    showCurrentTimeIndicator: true,
        showTodayButton: true,
        showDatePickerButton: true,
                  view: CalendarView.schedule,
                  allowedViews: const [
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.schedule,
                    CalendarView.workWeek,
                    CalendarView.timelineWorkWeek,
                    CalendarView.timelineMonth,
                    CalendarView.month,
                  ],
                  dataSource: AppointmentDataSource(_closedDays, _appointments),
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.appointment) {
                      final Appointment appointment = details.appointments!.first;
                      _showAppointmentDetailsDialog(appointment);
                    } else {
                      return;
                    }
                  },
                 ),
        ),
      ],
    );
  }
   final TextEditingController _barberNameController = TextEditingController();


    void _showAppointmentDetailsDialog(Appointment appointment) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        
        title: const Text('Randevu Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                ListTile(
                                    contentPadding: EdgeInsets.zero,

                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text('İsim-Soyisim'),
                  subtitle: Text(
                    '${appointment.subject}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ListTile(                  contentPadding: EdgeInsets.zero,

                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text('Telefon'),
                  subtitle: Text(
                    '${appointment.notes}',
                    style: const TextStyle(
                      fontSize: 15,
                       decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {
                    // HTML için telefon bağlantısı
                    final String telUrl = 'tel:${appointment.notes}';
                    html.window.location.href = telUrl;
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      final String telUrl = 'tel:${appointment.notes}';
                      html.window.location.href = telUrl;
                    },
                  ),
                ),
                ListTile(                  contentPadding: EdgeInsets.zero,

                  leading: const Icon(Icons.calendar_today, color: Colors.purple),
                  title: const Text('Tarih'),
                  subtitle: Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(appointment.startTime),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                ListTile(                  contentPadding: EdgeInsets.zero,

                  leading: const Icon(Icons.access_time, color: Colors.orange),
                  title: const Text('Başlangıç Saati'),
                  subtitle: Text(
                    DateFormat('HH:mm').format(appointment.startTime),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                ListTile(                  contentPadding: EdgeInsets.zero,

                  leading: const Icon(Icons.access_time_filled, color: Colors.red),
                  title: const Text('Bitiş Saati'),
                  subtitle: Text(
                    DateFormat('HH:mm').format(appointment.endTime),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
         
FutureBuilder<String?>(
  future: _checkAdminRole(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data == "admin") {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
        onPressed: () => _showDeleteAppointmentDialog(appointment),
        child: const Text('Randevuyu Sil'),
      );
    }
    return Container(); // Return empty container if not admin
  },
)
 ],
      );
    },
  );
}
  void _showAddBarberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Berber Ekle'),
          content: TextField(
            controller: _barberNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Barber İsmi',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                _addBarber();
                Navigator.of(context).pop();
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

void _addBarber() async {
  if (_barberNameController.text.isNotEmpty) {
    DocumentReference docRef = await FirebaseFirestore.instance.collection('barbers').add({
      'name': _barberNameController.text,
      'closedDays': [],
    });
    String docId = docRef.id;
    await docRef.update({'id': docId});
    
    _barberNameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barber added successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a name')),
    );
  }
}
  Future<void> _confirmDeleteBarber(String barberId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this barber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('barbers').doc(barberId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barber deleted successfully')),
      );
    }
  }

  Widget _buildBarberSelection() {        final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        AppBar(
automaticallyImplyLeading: false,
centerTitle: false,
        title: const Text("Berberler"),
        actions: [
isMobile ? IconButton(onPressed:_showSignOutConfirmation, icon: const Icon(Icons.logout),): Container(),const SizedBox(width: 5,)
        ]
      ),
 
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('barbers').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return ListTile(
                    title: Text(document.get('name')),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteBarber(document.id),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _barberNameController.dispose();
    super.dispose();
  }

  Widget _buildSettings() {
    return           _buildAddRemoveClosedDays();

  }

  Widget _buildAddRemoveClosedDays() {        final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
                AppBar(
automaticallyImplyLeading: false,
centerTitle: false,
        title: const Text("Kapalı Günler"),
        actions: [StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('barbers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return DropdownButton<String>(
              underline: const SizedBox(),
              hint: Text(_selectedBarberName ?? "Berber Seç"),
              value: _selectedBarberId,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBarberId = newValue;
                  _selectedBarberName = null;
                  _loadClosedDays();
                  _loadAppointments();
                });
                FirebaseFirestore.instance.collection('barbers').doc(newValue).get().then((doc) {
                  setState(() {
                    _selectedBarberName = doc['name'];
                  });
                });
              },
              items: snapshot.data!.docs.map((DocumentSnapshot document) {
                return DropdownMenuItem<String>(
                  value: document.id,
                  child: Text(document.get('name')),
                );
              }).toList(),
            );
          },
        ),  ...isMobile ? [
          const SizedBox(width: 5,),IconButton(onPressed:_showSignOutConfirmation, icon: const Icon(Icons.logout),),const SizedBox(width: 5,)
        ] : [Container()],
]
      ),
      
       const ListTile(
        title: Text('Randevuya Kapalı Günler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
       ),
        if (_closedDays.isNotEmpty)
          Column(
            children: _closedDays.map((date) {
                  String formattedDate = DateFormat('d MMMM EEEE, yyyy', 'tr_TR').format(date);

                  return ListTile(
                    title: Text(formattedDate),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeClosedDay(date),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }
 

  Future<void> _addClosedDay() async {
    if (_selectedDate != null && _selectedBarberId != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('barbers')
            .doc(_selectedBarberId)
            .update({
          'closedDays': FieldValue.arrayUnion([_selectedDate])
        });
        setState(() {
          _closedDays.add(_selectedDate!);
        });
        _showMessage('Kapalı gün eklendi.');
      } catch (e) {
        _showMessage('Hata oluştu: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeClosedDay(DateTime date) async {
    if (_selectedBarberId != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('barbers')
            .doc(_selectedBarberId)
            .update({
          'closedDays': FieldValue.arrayRemove([date])
        });
        setState(() {
          _closedDays.remove(date);
        });
        _showMessage('Kapalı gün kaldırıldı.');
      } catch (e) {
        _showMessage('Hata oluştu: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

void _showAddAppointmentDialog(DateTime dateTime) {
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Saat Aralığını Doldur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'Tarih Seç (${selectedDate != null ? DateFormat('d MMMM EEEE, yyyy', 'tr_TR').format(selectedDate!) : 'Seçilmedi'})',
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    'Başlangıç Saati Seç (${selectedStartTime != null ? selectedStartTime!.format(context) : 'Seçilmedi'})',
                  ),
                  onTap: selectedDate != null
                      ? () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime ?? TimeOfDay.now(),
                          );
                          if (picked != null && picked != selectedStartTime) {
                            setDialogState(() {
                              selectedStartTime = picked;
                            });
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    'Bitiş Saati Seç (${selectedEndTime != null ? selectedEndTime!.format(context) : 'Seçilmedi'})',
                  ),
                  onTap: selectedDate != null
                      ? () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime ?? TimeOfDay.now(),
                          );
                          if (picked != null && picked != selectedEndTime) {
                            setDialogState(() {
                              selectedEndTime = picked;
                            });
                          }
                        }
                      : null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: (selectedDate != null && selectedStartTime != null && selectedEndTime != null)
                    ? () {
                        _addAppointment(
                          DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedStartTime!.hour,
                            selectedStartTime!.minute,
                          ),
                          DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedEndTime!.hour,
                            selectedEndTime!.minute,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      );
    },
  );
}
  void _showDeleteAppointmentDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Randevuyu Sil'),
          content: const Text('Bu randevuyu silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _removeAppointment(appointment);
                Navigator.of(context).pop();
Navigator.of(context).pop();

              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(this.closedDays, this.appointments) {
    appointments = [
      ...closedDays.map(
        (date) => Appointment(
          startTime: date,
          endTime: date,
          subject: 'Kapalı',
          color: Colors.black,
          isAllDay: true,
        ),
      ),
      ...appointments,
    ];
  }

  final List<DateTime> closedDays;
  @override
  final List<Appointment> appointments;
}