import 'dart:ffi';

import 'package:blog_notas/photo_upload.dart';
import 'package:blog_notas/posts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Posts> postList = [];

  @override
  Void initState() {
    super.initState();
    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("Posts");

    postsRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      postList.clear();

      for (var individualkey in keys) {
        Posts posts = Posts(
          data[individualkey]["Image"],
          data[individualkey]["description"],
          data[individualkey]["date"],
          data[individualkey]["time"],
        );
        postList.add(posts);
      }

      setState(() {
        print("Lenght: $postList.lenght");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "home",
        ),
      ),
      body: Container(
        child: postList.length == 0
            ? Text("no hay blob disponible")
            : ListView.builder(
                itemCount: postList.length,
                itemBuilder: (_, index) {
                  return postsUI(
                    postList[index].image,
                    postList[index].description,
                    postList[index].date,
                    postList[index].time,
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo),
                iconSize: 40,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PhotoUpload();
                  }));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget postsUI(String image, String description, String date, String time){
    return Card(
      elevation: 10.0,
      margin: EdgeInsets.all(14.0),
      
      child: Container(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
              date,
              style:Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
              ),
            ],
           ) 
           SizedBox(height: 10.0,),
           Image.network(
            image,
            fit: BoxFit.cover,
           ),
           SizedBox(height: 10.0,),
           Text(
            description,
            style: Theme.of(context).textTheme.subhead,
            textAlign: TextAlign.center,
           )
          ],
        ),

      ), 
    );
  }
}
