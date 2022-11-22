// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_ui/auth/controller/authcontroller.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/features/chat/widgets/contacts_list.dart';
import 'package:whatsapp_ui/features/chat/widgets/searchresults.dart';
import 'package:whatsapp_ui/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_ui/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_ui/features/status/screens/status_contacts_screen.dart';
import 'package:whatsapp_ui/models/userModel.dart';
import 'package:whatsapp_ui/utils/utils.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({
    this.user,
  });
  final UserModel? user;

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver {
  int _index = 0;
  bool showSearchBar = false;
  String searchval = '';

  PageController _pageController = PageController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    searchval = '';
    _pageController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  List<Widget> screens = [
    ContactsList(),
    StatusContactsScreen(),
    Center(
      child: const Text('calls'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                //  showSnackBar(context: context, content: 'search');
                setState(() {
                  showSearchBar = !showSearchBar;
                  searchval = '';
                  //  showSnackBar(context: context, content: '$showSearchBar');
                });
              },
              icon: Icon(Icons.more_vert),
            )
          ],
          leading: GestureDetector(
            onTap: () {
              showSnackBar(context: context, content: 'Pic was clicked');
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.user!.profilePic),
                radius: 50,
              ),
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            systemNavigationBarDividerColor: Colors.white,
            systemNavigationBarColor: mobileChatBoxColor,
            statusBarColor: mobileChatBoxColor,
          ),
          elevation: 0,
          toolbarHeight: 65,
          backgroundColor: appBarColor,
          centerTitle: true,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 20,
              color: tabColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.search, color: Colors.grey),
          //     onPressed: () {},
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.more_vert, color: Colors.grey),
          //     onPressed: () {},
          //   ),
          // ],
          // bottom: const TabBar(
          //   indicatorColor: tabColor,
          //   indicatorWeight: 4,
          //   labelColor: tabColor,
          //   unselectedLabelColor: Colors.grey,
          //   labelStyle: TextStyle(
          //     fontWeight: FontWeight.bold,
          //   ),
          //   tabs: [
          //     Tab(
          //       text: 'CHATS',
          //     ),
          //     Tab(
          //       text: 'STATUS',
          //     ),
          //     Tab(
          //       text: 'CALLS',
          //     ),
          //   ],
          // ),
        ),
        body: PageView(
          children: screens,
          onPageChanged: (value) {
            setState(() {
              _index = value;
            });
          },
          controller: _pageController,
        ), //
        //   children: [
        //     showSearchBar == true
        //         ? Container(
        //             padding: const EdgeInsets.all(5.0),
        //             child: Container(
        //               //margin: const EdgeInsets.only(bottom: 20),
        //               padding: const EdgeInsets.all(14),
        //               decoration: BoxDecoration(
        //                 shape: BoxShape.rectangle,
        //                 color: mobileChatBoxColor,
        //                 border: Border.all(color: Colors.black),
        //                 borderRadius: BorderRadius.circular(20),
        //               ),
        //               child: TextFormField(
        //                 onChanged: (value) {
        //                   setState(() {
        //                     searchval = value;
        //                   });
        //                   // showSnackBar(context: context, content: searchval);
        //                 },
        //                 decoration: InputDecoration(
        //                     contentPadding: EdgeInsets.all(10),
        //                     label: Row(
        //                       children: const [
        //                         Icon(Icons.search),
        //                         SizedBox(
        //                           width: 20,
        //                         ),
        //                         Text("Search your contacts")
        //                       ],
        //                     )),
        //               ),
        //             ),
        //           )
        //         : const SizedBox(
        //             height: 0,
        //           ),
        //     // ignore: unnecessary_null_comparison
        //     searchval != null
        //         ? SearchResults(
        //             searchval: searchval.toLowerCase(),
        //           )
        //         : screens[_index]
        //   ],
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_index == 0) {
              Navigator.pushNamed(context, SelectContactScreen.routeName);
            } else {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, ConfirmStatusScreen.routeName,
                    arguments: pickedImage);
              }
            }
          },
          backgroundColor: tabColor,
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: mobileChatBoxColor,
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tabColor.withOpacity(0.8),
                  mobileChatBoxColor.withOpacity(0.8)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              backgroundColor: mobileChatBoxColor,
              iconSize: 20,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'chats',
                  backgroundColor: tabColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_half_outlined),
                  label: 'status',
                  backgroundColor: tabColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call),
                  label: 'calls',
                  backgroundColor: tabColor,
                ),
              ],
              onTap: (currentindex) {
                setState(() {
                  _index = currentindex;
                  _pageController.animateToPage(
                    _index,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.linear,
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
