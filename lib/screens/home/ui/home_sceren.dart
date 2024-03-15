// ignore_for_file: unused_import, prefer_const_constructors

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:last/navigation_bar.dart';

import '../../../core/widgets/no_internet.dart';
import '../../../theming/colors.dart';
import '/helpers/extensions.dart';
import '/routing/routes.dart';
import '/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(children: [
        OfflineBuilder(
          connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
          ) {
            final bool connected = connectivity != ConnectivityResult.none;
            return connected ? _homePage(context) : const BuildNoInternet();
          },
          child: const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 92, 113, 207),
            ),
          ),
        ),
        Nav(),
      ]),
    );
  }

  SafeArea _homePage(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 200),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 60, 0, 20),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: FirebaseAuth.instance.currentUser!.photoURL == null
                        ? Image.asset('assets/images/placeholder.png')
                        : FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading.gif',
                            image: FirebaseAuth.instance.currentUser!.photoURL!,
                            fit: BoxFit.cover,
                          ),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    FirebaseAuth.instance.currentUser!.displayName!,
                    style: TextStyles.font14Grey400Weight
                        .copyWith(fontSize: 25.sp),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    style: TextStyles.font14Grey400Weight
                        .copyWith(fontSize: 20.sp),
                  )),
              Padding(padding: EdgeInsets.fromLTRB(60, 0, 60, 0) ,child:AppTextButton(
                buttonText: 'Sign Out',
                textStyle: TextStyles.font16White600Weight,
                backgroundColor: Color.fromARGB(255, 92, 113, 207),
                onPressed: () async {
                  try {
                    FirebaseAuth.instance.signOut();
                    context.pushNamedAndRemoveUntil(
                      Routes.loginScreen,
                      predicate: (route) => false,
                    );
                  } catch (e) {
                    await AwesomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: 'Sign out error',
                      desc: e.toString(),
                    ).show();
                  }
                },
              )
          )
            ],
          ),
        ),
      ),
    );
  }
}
