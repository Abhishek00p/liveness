import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liveness/blocs/cameraController_cubit.dart';
import 'package:liveness/camera_page.dart';
import 'package:liveness/blocs/face_detection_cubit.dart';
import 'package:liveness/blocs/isListening_cubit.dart';
import 'package:liveness/blocs/spoken_number_cubit.dart';
import 'package:liveness/blocs/user_location_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:svg_flutter/svg_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FaceDetectionCubit(),
        ),
        BlocProvider(
          create: (context) => SpokenNumber(),
        ),
        BlocProvider(
          create: (context) => IsAudioListening(),
        ),
        BlocProvider(
          create: (context) => UserLocation(),
        ),
        BlocProvider(
          create: (context) => CameraControllerCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Liveness Check',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color.fromRGBO(28, 28, 28, 1),
              height: 60,
              child: Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        'assets/drawer_icon.png',
                        height: 40,
                        width: 50,
                      ),
                      Image.asset(
                        'assets/keev_logo.png',
                        height: 40,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Image.asset('assets/profile_image.png'),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    padding: const EdgeInsets.all(16),
                    // width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.grey[300],
                    child: CircleAvatar(
                      backgroundColor: Colors.amberAccent,
                      radius: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _enableCameraAccess(context);
                    },
                    child: const Text('Enable Camera'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              height: 60,
              color: const Color(0xFF103566),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.star_border,
                        color: Colors.white,
                      ),
                      Text('My Keev', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/apply_now.png'),
                      const Text('Apply Now', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset('assets/credit_card.svg'),
                      const Text('Credit Card',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.local_printshop_outlined,
                        color: Colors.white,
                      ),
                      Text('Service Request',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset('assets/investment.svg'),
                      const Text(
                        'Investment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enableCameraAccess(BuildContext context) async {
    var status = await Permission.camera.status;
    const camPermission = Permission.camera;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      status = await Permission.camera.request();
      // try {
      //   await ImagePicker().pickImage(source: ImageSource.camera);
      // } catch (e) {
      //   debugPrint('error while getting status');
      // }
    }

    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );
    } else {
      // Camera access not granted
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Camera Access'),
            content:
                const Text('Camera access is required for to Check your Liveness.'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final status0 = await Permission.camera.request();
                  debugPrint(status0.name);
                  if (status0.isGranted) {
                    // Camera access granted, navigate to next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CameraPage()),
                    );
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
