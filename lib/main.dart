import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:excel/excel.dart';
import 'DatabaseHelper/databasehelper.dart';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';

void sendBulkEmails() async {
  List<String> emails = await DatabaseHelper.instance.getEmails();
  final Email email = Email(

    body: 'shiyaam',
    subject: 'Your subject',
    recipients: emails,
    isHTML: false,
  );

  try {
    await FlutterEmailSender.send(email);
    print('Email(s) sent successfully.');
  } catch (error) {
    print('Error sending email(s): $error');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ABSOLUTE'),
          backgroundColor: Colors.red,
        ),
        body: Home()
      ),
    );
  }
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  List<List<dynamic>> csvData = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller1  = TextEditingController();

  Future<void> _parseCSV() async {
    List<String> databaseEmail = await DatabaseHelper.instance.getEmails();
    // Allow user to pick a CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null) {
        String rawCsv = await File(filePath).readAsString();
        List<List<dynamic>> rowsAsListOfValues = CsvToListConverter().convert(rawCsv);

        setState(() {
          csvData = rowsAsListOfValues;
        });

        // Extracting emails from the CSV data
        List<String> emails = [];
        for (var i = 1; i < csvData.length; i++) {
          String email = csvData[i][0].toString(); // Assuming email is in the first column
          emails.add(email);
          if(!databaseEmail.contains(email) && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)){
            addEmails(email);
          }else{
            print(emails);
          }

        }
        print(emails);

        // Save emails to the database

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/absolute.png'), // Replace with your image path
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 80,),
          Center(
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                   // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Button border radius
                  ),
                ),
                onPressed: sendBulkEmails,
                child: Text('Send Email ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Button border radius
                  ),
                ),
                onPressed: () async{
                  /*showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:  Container(
                            width: 250,
                            decoration: const BoxDecoration(
                              // color: Color.fromARGB(255, 5, 61, 124),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Add Email",

                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 20,
                                        ))
                                  ],
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                              ],
                            )),
                        titlePadding: const EdgeInsets.all(0),
                        contentPadding: const EdgeInsets.all(0) ,
                        content: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Email'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 60,

                                  child:  TextFormField(

                                      cursorColor: Colors.black,

                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                      ],
                                      style: TextStyle(color: Colors.black,fontSize: 14 ),
                                      controller: controller1,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter an email';
                                        }
                                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },





                                      // controller: Controllers.quotationSearch,

                                      decoration: InputDecoration(
                                        // isDense: true,

                                        contentPadding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 1.0),
                                        fillColor:Colors.white38,

                                        hintStyle: TextStyle(fontSize: 14 ),
                                        focusedBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(120.0),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(63, 4, 60, 124),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(120.0),
                                          borderSide: BorderSide(
                                            color:Color.fromARGB(63, 4, 60, 124),
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(120.0),
                                          borderSide: BorderSide(
                                            color:Color.fromARGB(63, 4, 60, 124),
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          // borderRadius: BorderRadius.circular(120.0),
                                          borderSide: BorderSide(
                                            color:Color.fromARGB(63, 4, 60, 124),
                                            width: 1.0,
                                          ),
                                        ),

                                      ),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (value){
                                        FocusScope.of(context).nextFocus();
                                      }



                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Add'),
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                                await DatabaseHelper.instance.insertEmail(controller1.text);
                                print('student added');
                                print('Email inserted!');
                                controller1.clear();
                                Navigator.of(context).pop();
                              }



                            },
                          ),
                        ],
                      );
                    },
                  );*/
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(10.0))),
                        title:Container(
                            width: 250,
                            decoration: const BoxDecoration(
                              // color: Color.fromARGB(255, 5, 61, 124),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Add Email",

                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 20,
                                        ))
                                  ],
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                              ],
                            )) ,
                        content: Builder(
                          builder: (context) {
                            // Get available height and width of the build area of this widget. Make a choice depending on the size.
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Container(
                              height: height - 650,
                              width: width - 400,
                              child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Email'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 60,

                                      child:  TextFormField(

                                          cursorColor: Colors.black,

                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(50),
                                          ],
                                          style: TextStyle(color: Colors.black,fontSize: 14 ),
                                          controller: controller1,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter an email';
                                            }
                                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },





                                          // controller: Controllers.quotationSearch,

                                          decoration: InputDecoration(
                                            // isDense: true,

                                            contentPadding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 1.0),
                                            fillColor:Colors.white38,

                                            hintStyle: TextStyle(fontSize: 14 ),
                                            focusedBorder: OutlineInputBorder(
                                              // borderRadius: BorderRadius.circular(120.0),
                                              borderSide: BorderSide(
                                                color: Color.fromARGB(63, 4, 60, 124),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              // borderRadius: BorderRadius.circular(120.0),
                                              borderSide: BorderSide(
                                                color:Color.fromARGB(63, 4, 60, 124),
                                                width: 1.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              // borderRadius: BorderRadius.circular(120.0),
                                              borderSide: BorderSide(
                                                color:Color.fromARGB(63, 4, 60, 124),
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              // borderRadius: BorderRadius.circular(120.0),
                                              borderSide: BorderSide(
                                                color:Color.fromARGB(63, 4, 60, 124),
                                                width: 1.0,
                                              ),
                                            ),

                                          ),
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (value){
                                            FocusScope.of(context).nextFocus();
                                          }



                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            );
                          },
                        ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Add'),
                              onPressed: () async{
                                if (_formKey.currentState!.validate()) {
                                  await DatabaseHelper.instance.insertEmail(controller1.text);
                                  print('Email inserted!');
                                  controller1.clear();
                                  Navigator.of(context).pop();
                                }



                              },
                            ),
                          ],
                      )
                  );


                },
                child: Text('Add Email',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
              ),
            ),
          ),
          SizedBox(height: 80,),
          Center(child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Button border radius
                    ),
                  ),
                  onPressed: getExcel, child: Text('Export CSV'))))
        ],
      ) ,
    );
  }

  void addEmails(value) async{
    await DatabaseHelper.instance.insertEmail(value);
  }
  Future<void> _parseExcel() async {
    ByteData data = await rootBundle.load('assets/test.xlsx');
    // Process the file data
  }
  Future<void> getExcel() async{
    print(await rootBundle.load('D:/purealpha/RIS/absolute/assets/test.xlsx'));
    var file = 'D:/purealpha/RIS/absolute/assets/test.xlsx';
    var bytes = File(file).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]!.maxCols);
      print(excel.tables[table]!.maxRows);
      for (var row in excel.tables[table]!.rows) {
        print('$row');
      }
    }
  }




}
