import 'package:blog_notas/Home_Page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:intl/intl.dart';   

class PhotoUpload extends StatefulWidget {
  @override
  _PhotoUploadState createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  File sampleImage; //imagen
  String _myValue;   //description
  String url, //url de la imagen
  final formkey = GlobalKey<FormState>();

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("descargar imagen"),
        centerTitle: true,
      ), 
      body: Center(
        child:sampleImage == null 
          ? Text("selecioar imagen") 
          : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: "añadir imagen",
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                Image.file(
                  sampleImage,
                  height: 300.0,
                  width: 600.0,
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "description"
                  ),
                  validator: (value){
                    return value.isEmpty? "la descripcion es requerida": null; l
                  },
                  onSaved: (value){
                   return _myValue = value;
                  },
                ),
                   
                  SizedBox(
                    height: 15.0,
                  ),
                  RaisedButton(
                    elevation:10.0,
                    child: Text("Add a New  Post"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: uploadStatusImage(),                 
                  )
                
              ],
            ),
          ),
        ),
      ),
    );
  }
   void uploadStatusImage() async{
    if(validateAndSave()){
      final StorageReference postImageRef =  FirebaseStorage.instance.ref().child("Publicar imagen");

      var timekey = DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timekey.toString()+ ".jpg").putfile(sampleImage);
      var imageUrl = await(await uploadTask.onComplete).ref.getDownloadUrl();
      url = imageUrl.toString();
      print("url de imagen: "+ url);

      //para guardar las imagenes

      saveToDatabase(url);

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(

        builder: (context){
          return HomePage();
        },
      ),
      );

    }
   }
    void saveToDatabase(String url){
      var  dbTimekey = DateTime.now();
      var formatDate = DateFormat("MMM d, yyyy'");
      var formatTime = DateFormat("EEEE, hh:mm");

      String date = formatDate.format(dbTimekey);
      String time = formatDate.format(dbTimekey);

      DatabaseReference ref = FirebaseDatabase.instance.reference(); 
      var data = {
        "image": url,
        "description": date,
        "time":time 
      };
      ref.child("publicaiones").push().set(data);

    }


  bool validateAndSave(){
     final form = formkey.currentState;
     if(form.validate(){
      form.save();
      return true;
     }else{
      return false;
     }
  }
}
