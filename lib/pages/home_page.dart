import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/pages/pageInPage/home.dart';
import 'package:like_app/pages/pageInPage/likes.dart';
import 'package:like_app/pages/pageInPage/postPage/post.dart';
import 'package:like_app/pages/pageInPage/profilePage/profilePage.dart';
import 'package:like_app/pages/pageInPage/search.dart';
import 'package:like_app/pages/searchPage.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthServie authServie = AuthServie();

  String userName = "";
  String email = "";

  bool isEmailVerified = false;

  static List<File> selectedImages = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {

    await HelperFunctions.getUserEmailFromSF().then((value) => {
      setState(() {
        email = value!;
      })
    });

    await HelperFunctions.getUserNameFromSF().then((value) => {
      setState(() {
        userName = value!;
      })
    });

  }

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Likes(),
    Post(files: selectedImages),    // renew widget Options !!!!!! // the imags problem
    Search(),
    ProfilePage()
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    double toolbarHeight = MediaQuery.of(context).size.height * 0.08;
    double sizedBox;
    double iconSize = MediaQuery.of(context).size.height * 0.023;

    bool isTablet;

    if(Device.get().isTablet) {
      isTablet = true;
      sizedBox = MediaQuery.of(context).size.height * 0.00;
    }
    else {
      isTablet = false;
      sizedBox = MediaQuery.of(context).size.height * 0.047;
    }
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
        toolbarHeight: toolbarHeight,
        
        actions: [
          IconButton(onPressed: (){
            nextScreen(context, const SearchPage());
          },
          icon: const Icon(
            Icons.search
          ),)
        ],

        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "LikeApp",
          style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500, fontSize:  MediaQuery.of(context).size.height * 0.0205
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey,
            ),
            const SizedBox(height: 15,),
            Text(userName),
            Text(email),
            ElevatedButton(
            child: Text("LOGOUT"),
            onPressed: () {
              authServie.signOut();
              nextScreen(context, const LoginPage());
            },)
          ],
        ),
      ),

      body: 
        SingleChildScrollView(
          child:Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                SizedBox(height: sizedBox,),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.only(
                    //   topRight: Radius.circular(borderCircular),
                    //   topLeft: Radius.circular(borderCircular),
                    // ),
                  ),
                  child: Center(
                    child: _widgetOptions.elementAt(selectedIndex),
                  )
                ),
              ]
            ),
          ),
        ),
      
      bottomNavigationBar: isTablet?
        SalomonBottomBar(
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined, size: iconSize,),
            title: Text("home"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border, size: iconSize,),
            title: Text("likes"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.post_add_outlined, size: iconSize,),
            title: Text("post"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search, size: iconSize,),
            title: Text("search"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person_2_outlined, size: iconSize,),
            title: Text("profile"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
          onTap: (index) {
          setState(() {
            if (index == 2) {
              _showPicMenu();
            }
            else {
              selectedIndex = index;
            }
          });
        },
      ) :
      SalomonBottomBar(
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined),
            title: Text("home"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("likes"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.post_add_outlined),
            title: Text("post"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("search"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person_2_outlined),
            title: Text("profile"),
            selectedColor:
                Theme.of(context).primaryColor
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
          onTap: (index) {
          setState(() {
            if (index == 2) {
              _showPicMenu();
            }
            else {
              selectedIndex = index;
            }
          });
        },
      ),
    );
  }

  Future getImages() async {
    selectedImages = [];
    try {
      final pickedFile = await picker.pickMultiImage(
        imageQuality: 50, maxHeight: 1000, maxWidth: 1000);
        List<XFile> xfilePick = pickedFile;
        setState(
          () {
            if (xfilePick.isNotEmpty) {
              for (var i = 0; i < xfilePick.length; i++) {
                selectedImages.add(File(xfilePick[i].path));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nothing is selected')));
            }
          },
        );

    } catch (e) {
      print(e);
    }
  }

  void _showPicMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0)
        )
      ),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_in_picture_alt),
                title: Text('No photo'),
                onTap: () {
                  setState(() {
                    _widgetOptions[2] = Post(files: []);
                    selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text('Select photo'),
                onTap: () async{
                  await getImages();
                  setState(() {
                    _widgetOptions[2] = Post(files: selectedImages);
                    selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
            ],
          ),
        );
      }
    );
  }
}