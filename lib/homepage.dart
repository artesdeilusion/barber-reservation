 import 'package:barber_reservation/admin/handleauth.dart';
import 'package:barber_reservation/artesdeilusion/blackbox.dart';
import 'package:barber_reservation/check_reservation/check_reservation.dart';
import 'package:barber_reservation/create_reservation/create_reservation.dart';
import 'package:barber_reservation/prices/pricetable.dart';
 import 'package:flutter/material.dart';
 
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   bool hasError = false;

  @override
  void initState() {
    super.initState();
   }
 
 

   Future<void> _openURL(String url) async {
    try {
      html.window.open(url, '_blank'); // Opens the URL in a new tab
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton:BlackBox(),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: isMobile
              ? Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5))
              : null,
          color: Colors.white,
        ),
        height: kBottomNavigationBarHeight,
        child: ButtonBar(
          children: [
            // Destek Button - Opens external help page
            TextButton(
              onPressed: () {
                showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
                  title: const Text("Destek"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        onTap: () {
                          
                        },
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Telefon Numarası"),
                        subtitle: const Text("+5952132"),
                      ),
                       ListTile(   onTap: () {
                          
                        },                        contentPadding: EdgeInsets.zero,

                        title: const Text("Adres"),
                        subtitle: const Text("Adliajfşaskd"),
                      ),
                    ],
                  ),
                ); }, );
               },
              child: const Text("Destek"),
            ),
            // Yönetici Button - Navigates to AdminPage
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const HandleAuthPage();
                  },
                ));
              },
              child: const Text("Yönetici"),
            ),
            // Çıkış Button - Shows sign-out confirmation dialog
           
          ],
        ),
      ),
      key: _scaffoldKey,
      body: hasError
              ? const Center(
                  child: Text('An error occurred while fetching data.'))
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth > 800) {
                      // Desktop & Tablet layout
                      return Row(
                        children: _buildUI(context),
                      );
                    } else {
                      // Mobile layout
                      return SingleChildScrollView(
                        // Scrollable for mobile view
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildUIMobile(context),
                        ),
                      );
                    }
                  },
                ),
    );
  }

  List<Widget> _buildUI(BuildContext context) {
    return [
      Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            image: const NetworkImage(
              "https://nationalbarbers.org/wp-content/uploads/2021/07/Untitled-design-18.png",
            ),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), // Adjust the opacity as needed
              BlendMode.darken,
            ),
          )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                          bottom: Radius.circular(25)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.4,
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, top: 30, bottom: 20),
                        child:  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("Salon Adliye | Randevu",
                                          style: TextStyle(
                                            fontSize: 25,
                                          )),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        height: 30,
                                      ),
                                           Card(         
                              clipBehavior: Clip.antiAlias,              
                              margin: EdgeInsets.zero,
                              child:  InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(barrierDismissible: true,builder:(context) {
                                    return const CreateReservation();
                                  },
                                  ));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.add
                                    ),
                                     title: Text(
                                      
                                      "Randevu Oluştur"
                                    ),
                                  ),
                                ),
                              ),
                            ), 
                            const SizedBox(height: 10,),
                            Card(                                       clipBehavior: Clip.antiAlias,              
              
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(barrierDismissible: true,builder:(context) {
                                    return const CheckReservation();
                                  },
                                  ));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.free_cancellation
                                    ),
                                     title: Text(
                                      
                                      "Randevu Sorgula"
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Card(                       
                              clipBehavior: Clip.antiAlias,              
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(barrierDismissible: true,builder:(context) {
                                    return const PriceTable();
                                  },
                                  ));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.currency_lira
                                    ),
                                     title: Text(
                                      
                                      "Fiyat Tablosu"
                                    ),
                                  ),
                                ),
                              ),
                            )
                            
                                    ],
                                  ))),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: const Card()),
            ],
          )),
    ];
  }

  List<Widget> _buildUIMobile(BuildContext context) {
    return [
      Center(
          child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child:   Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Salon Adliye | Randevu",
                                style: TextStyle(
                                  fontSize: 25,
                                )),
                            Divider(
                              color: Colors.grey.shade300,
                              height: 30,
                            ),
                            Card(         
                              clipBehavior: Clip.antiAlias,              
                              margin: EdgeInsets.zero,
                              child:  InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(barrierDismissible: true,builder:(context) {
                                    return const CreateReservation();
                                  },
                                  ));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.add
                                    ),
                                     title: Text(
                                      
                                      "Randevu Oluştur"
                                    ),
                                  ),
                                ),
                              ),
                            ), 
                            const SizedBox(height: 10,),
                            Card(                                       clipBehavior: Clip.antiAlias,              
              
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(barrierDismissible: true,builder:(context) {
                                    return const CheckReservation();
                                  },
                                  ));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.free_cancellation
                                    ),
                                     title: Text(
                                      
                                      "Randevu Sorgula"
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Card(                                 clipBehavior: Clip.antiAlias,              
                    
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(barrierDismissible: true,builder:(context) {
                                    return const PriceTable();
                                  },
                                  ));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.currency_lira
                                    ),
                                     title: Text(
                                      
                                      "Fiyat Tablosu"
                                    ),
                                  ),
                                ),
                              ),
                            )
                            
                          ],
                        )))
    ];
  }
}
