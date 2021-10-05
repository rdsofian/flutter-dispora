import 'dart:convert';

import 'package:dispora/api/desa.api.dart';
import 'package:dispora/configs/app.config.dart';
import 'package:dispora/models/dashboard.model.dart';
import 'package:dispora/widgets/dashboard.box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

import 'detail.dashboard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({ Key? key }) : super(key: key);
  

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final PageStorageBucket bucket = PageStorageBucket();
  List news = List.empty();

  @override 
  void initState() {
    super.initState();
    getData();
  }
  AppConfig config = AppConfig();

  Future<String> getData() async {

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      var response = await http.get(Uri.parse("${config.apiURL}/get-dashboard"),
          headers: requestHeaders);

    setState(() {
      //RESPONSE YANG DIDAPATKAN DARI API TERSEBUT DI DECODE
      var content = json.decode(response.body);
      //KEMUDIAN DATANYA DISIMPAN KE DALAM VARIABLE data,
      //DIMANA SECARA SPESIFIK YANG INGIN KITA AMBIL ADALAH ISI DARI KEY hasil
      news = content;
    });
    return 'success!';
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.green[200],
      body: PageStorage(
        child:  _body() ,
        bucket: bucket,
      ));
  }

  _body() {
    PageController controller = PageController(initialPage: 0, viewportFraction: 1);
    List<String> urls = [
      // "https://mi.lpkia.ac.id/wp-content/uploads/2021/09/gubernur.jpg",
      // "https://mi.lpkia.ac.id/wp-content/uploads/2021/09/kadis.jpg"
      "${config.apiURL}/public/img/kadis.png",
      "${config.apiURL}/public/img/gubernur.png"
    ];
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: <Widget>[
          _top('${config.apiURL}/public/img/bedas.png'),
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: controller,
                itemCount: urls.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    children: [
                      DashboardBox(urls[index]),
                    ],
                  ),
                )
              ),
            ),
          ),

          Padding(
            padding:const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text(
                  "Berita",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      fontFamily: 'Nunito'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
                itemCount: news == null ? 0 : news.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    height: 225,
                    width: double.maxFinite,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      elevation: 0,
                      
                      child: InkWell(
                        onTap: () {
                          int idDesa = news[index]['id_desa'];
                          ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            content: Text('Selected Desa: ${idDesa.toString()}')
                            ));

                            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDashboard(idDesa: idDesa, namaDesa: '')));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Stack(children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 5),
                                      child: Column(
                                        children: <Widget>[
                                          fotoDesa(news[index]['foto']),
                                          // fotoDesa("${config.apiURL}/public/img/dispora.png"),
                                          desaKecamatan(news[index]['nama_desa'], news[index]['nama_kecamatan']),
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ]),
                        ),
                      ),
                      
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  _top(urlLogo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 40, 15, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.green,
                Colors.limeAccent
              ],
        ),
        // color: Color(0xFF30FF29),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                },
                // child: const CircleAvatar(
                //   backgroundImage: Image.network('${urlLogo}'),
                // ),
                child: Image.network('${urlLogo}',
                  width: 40,
                ),
              ),
            
              const SizedBox(
                width: 10.0,
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                color: Colors.white,
                onPressed: () {
                },
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          
          TypeAheadField<DashboardModel?>(

            debounceDuration: const Duration(milliseconds: 500),
            // hideSuggestionsOnKeyboardHide: false,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                hintText: "Pencarian Desa",
                fillColor: Colors.white,
                filled: true,
                suffixIcon: const Icon(Icons.filter_list),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.transparent)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)),
            ),
            suggestionsCallback: DesaApi.getDesaSugestion, 
            itemBuilder: (context, DashboardModel? suggestion) {
              final desa = suggestion!;

              return ListTile(
                title: Text(desa.namaDesa),
              );
            },
            noItemsFoundBuilder: (context) => const SizedBox(
              height: 100,
              child: Text('Desa Tidak Ditemukan',
                style: TextStyle(fontSize: 24),),),
            onSuggestionSelected: (DashboardModel? suggestion) {
              final desa = suggestion!;

              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text('Selected Desa: ${desa.namaDesa}')
                  ));
               Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDashboard(idDesa: 0, namaDesa: desa.namaDesa)));
            },
          ),
          
        ],
      ),
    );
  }
}

Widget desaKecamatan(desa, kecamatan) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '\n${kecamatan}',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito'),
                children: <TextSpan>[
                  TextSpan(
                      text: '\nDesa ${desa}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget fotoDesa(foto) {
  
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              //Hari dan Tanggal
              Row(
                mainAxisAlignment : MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget> [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        //  "${config.apiURL}/public/img/kadis.png",
                          "${foto}",
                          width: 322,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                    )
                ]
              ),
            ],
          ),
      ),
    );
  }
