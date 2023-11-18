import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/widget/searchName.dart';
import 'package:like_app/widget/searchTag.dart';
import 'package:like_app/widget/searchUser.dart';
import 'package:like_app/widgets/widgets.dart';

class Search extends StatefulWidget {

  final String searchName;

  const Search({super.key, required this.searchName});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  TextEditingController? searchController;

  String? uId = "";

  bool isUIdLoading = true;

  bool isErrorOccurred = false;

  int _currentIndex = 0;

  @override
  void initState() {
    try {
      searchController = new TextEditingController(text: widget.searchName);
      _tabController = TabController(
        length: 3,
        vsync: this, 
      );
      getUId();

      _tabController.addListener(() {
        setState(() {
          _currentIndex = _tabController.index;
        });
        print("Selected Index: " + _tabController.index.toString());
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController!.dispose();
    _tabController.dispose();
  }

  void getUId() async{
    try {
      await HelperFunctions.getUserUIdFromSF().then((value) => {
        uId = value,
        if (this.mounted) {
          setState(() {
            isUIdLoading = false;
          })
        }
      });
    } catch(e) {
      setState(() {
        isErrorOccurred = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final _tabContent = <Widget>[
      searchController!.text == "" ? 
            Container() : 
            SearchName(searchedName: searchController!.text, uId: uId!),
      searchController!.text == "" ? 
            Container() :
            SearchUser(searchedName: searchController!.text, uId: uId!),
      searchController!.text == "" ? 
            Container() :
            SearchTag(searchedName: searchController!.text, uId: uId!)
    ];

    return isUIdLoading ? 
      Center(
        child: CircularProgressIndicator(),
      )
      : 
      Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.07,
          backgroundColor: Theme.of(context).primaryColor,
          title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none
                ),
                hintText: "Search anything",
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.white
              ),
              onFieldSubmitted: (String _) {
                if (this.mounted) {
                  if (_ != "") {
                    setState(() {
                      nextScreenReplace(context, Search(searchName: _));
                    });
                  }
                }
              },
            ),
            bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(text: "posts",),
                  Tab(text: "account",),
                  Tab(text: "tags",)
                ],
              )
          ),
        body:

        IndexedStack(
          index: _currentIndex,
          children: _tabContent,
        ),
      );
  }
}