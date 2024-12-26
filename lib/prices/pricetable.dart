import 'package:flutter/material.dart';

class PriceTable extends StatelessWidget {
  const PriceTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiyat Listesi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hakim, Savcı, Avukat Fiyat Listesi",style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold
            ),),
            const SizedBox(height: 10,),
            Table(
              border: TableBorder.all(),
              children: const [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hizmet', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Fiyat', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saç Kesimi + Yıkama'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('300 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sakal Kesimi'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('150 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saç Yıkama'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('100 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Kulak-Yanak Ağda'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('50 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Ense Alma-Düzeltme'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('50 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saç Renklendirme'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('100 TL'),
                    ),
                  ],
                ),
              ],
            ),

const SizedBox(height: 20,),

              const Text("Personel Fiyat Listesi",style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold
            ),),
            const SizedBox(height: 10,),
           Table(
              border: TableBorder.all(),
              children: const [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hizmet', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Fiyat', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saç Kesimi + Yıkama'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('300 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sakal Kesimi'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('150 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saç Yıkama'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('100 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Kulak-Yanak Ağda'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('50 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Ense Alma-Düzeltme'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('50 TL'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saç Renklendirme'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('100 TL'),
                    ),
                  ],
                ),
              ],
            ),
  ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PriceTable(),
  ));
}