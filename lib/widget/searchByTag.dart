import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/pages/pageInPage/search.dart';
import 'package:like_app/widget/searchName.dart';
import 'package:like_app/widget/searchTag.dart';
import 'package:like_app/widget/searchUser.dart';
import 'package:like_app/widgets/widgets.dart';

class SearchByTag extends StatefulWidget {

  final String searchText;

  const SearchByTag({super.key, required this.searchText});

  @override
  State<SearchByTag> createState() => _SearchByTagState();
}

class _SearchByTagState extends State<SearchByTag> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  String? uId = "";

  bool isUIdLoading = true;

  // bool isProfileLoading = true;
  // String profile = "";

  int _currentIndex = 2;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 2,
      length: 3,
      vsync: this,
    );
    getUId();

    _tabController.addListener(() {
      if (this.mounted) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });

    super.initState();
  }

  void getUId() async{
    await HelperFunctions.getUserUIdFromSF().then((value) => {
      uId = value,
      if (this.mounted) {
        setState(() {
          isUIdLoading = false;
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final TextEditingController searchController = new TextEditingController(text: widget.searchText);

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

    return isUIdLoading? 
      Center(
        child: CircularProgressIndicator(),
      )
      : 
      Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.07,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: MediaQuery.of(context).size.width * 0.06,),
            onPressed: () => nextScreen(context, HomePage())
          ),
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
                ]
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