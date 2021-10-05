import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dispora/models/dashboard.model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dispora/configs/app.config.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DetailDashboard extends StatefulWidget {
  final int idDesa;
  final String namaDesa;
  const DetailDashboard({ Key? key, required this.idDesa, required this.namaDesa }) : super(key: key);
  @override
  _DetailDashboardState createState() => _DetailDashboardState();
}

class _DetailDashboardState extends State<DetailDashboard> {
    List village = List.empty();
    late bool isLoading;
    bool _allowWriteFile=false;
    late Dio dio;
    String progress="";
    int id = 0;
  late Future<DashboardModel> dashboardModel;
  @override 
  void initState() {
    super.initState();
    id = widget.idDesa;
    dio=Dio();
    dashboardModel = getData();
  }

  AppConfig config = AppConfig();

 Future<String>getDirectoryPath() async
  {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    Directory directory= await new Directory(appDocDirectory.path+'/'+'dir').create(recursive: true);

    return directory.path;
  }

  Future downloadFile(String url,path) async {
    print(path);
    if(!_allowWriteFile)
    {

      requestWritePermission();
    }
    try{
      ProgressDialog progressDialog=ProgressDialog(context,dialogTransitionType: DialogTransitionType.Bubble,title: const Text("Downloading File"));

      progressDialog.show();



      await dio.download(url, path,onReceiveProgress: (rec,total){
        setState(() {
          isLoading=true;
          progress=((rec/total)*100).toStringAsFixed(0)+"%";
          progressDialog.setMessage(Text( "Dowloading $progress"));
        });

      });
      progressDialog.dismiss();

    }catch( e)
    {

      print(e.toString());
    }
  }
  
  Future<DashboardModel> getData() async {
      
      var jsonResponse = null;
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      int idDesa = widget.idDesa == 0 ? 0 : widget.idDesa;
      String namaDesa = widget.namaDesa == '' ? "kosong" : widget.namaDesa;
      var response = await http.get(Uri.parse("${config.apiURL}/get-village/${idDesa}/${namaDesa}"),
          headers: requestHeaders);

      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);

        DashboardModel dashboardModel = new DashboardModel(
          idDesa: jsonResponse[0]['id_desa'],
          namaDesa: jsonResponse[0]['nama_desa'],
          namaKecamatan: jsonResponse[0]['nama_kecamatan'],
          foto: jsonResponse[0]['foto'],
        );
        setState(() {
          id = jsonResponse[0]['id_desa'];
        });

        return dashboardModel;
      } else {
        throw Exception('Failed to load Data');
      }
  }


  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            color: Colors.grey[200],
            child: Column(
              children: <Widget>[
                _top(),
                _buildInfoCard(),
                const SizedBox(height: 30),
               TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      // _requestDownload('http://student.lpkia.ac.id/files/panduan_akademik_poltek.pdf');
                        // String url = 'http://student.lpkia.ac.id/files/panduan_akademik_poltek.pdf';
                      
                        String url = '${config.apiURL}/public/pdf/${this.id}.pdf';
                        String extension=url.substring(url.lastIndexOf("/"));
                       
                        getDirectoryPath().then((path) {
                           
                          File f=File(path+"$extension");
                          if(f.existsSync())
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return PDFScreen(f.path);
                            }));
                            return;
                          }

                          downloadFile(url,"$path$extension");
                        });
                    },
                    child: const Text('Download'),
                  ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.picture_as_pdf),
          //   onPressed: () => {},
          //   foregroundColor: Colors.white,
          //   backgroundColor: Color(0xFF2979FF),
          // ),
        ));
  }

  
  _top() {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 0),
      decoration:  const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.green,
                Colors.limeAccent
              ],
        ),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 100),
            child: const Text(
              "DATA DESA",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  _buildInfoCard() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5.0,
            color: Colors.white,
            child: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(15),
          child: FutureBuilder<DashboardModel>(
            future: dashboardModel,
              builder: (context, snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {
                  children = <Widget>[
                    ListTile(
                      leading: const Icon(Icons.holiday_village, color: Color(0xFF2979FF)),
                      title: const Text(
                        "Nama Kecamatan",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        snapshot.data!.namaKecamatan,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.home, color: Color(0xFF2979FF)),
                      title: const Text("Nama Desa",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                      subtitle: Text(snapshot.data!.namaDesa,
                          style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Nunito',
                              color: Colors.black54)),
                    ),
                    
                  ];
                  return Center(child: Column(children: children));
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ), 
          ),
        ),
      ],
    );
  }

   requestWritePermission() async {

    if (await Permission.storage.request().isGranted) {
      setState(() {
        _allowWriteFile = true;

      });
    }else
      {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
      }

  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return  SfPdfViewer.file(
      File(pathPDF),
      key: _pdfViewerKey,
    );
  }
}
