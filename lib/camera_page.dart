import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liveness/blocs/cameraController_cubit.dart';
import 'package:liveness/blocs/face_detection_cubit.dart';
import 'package:liveness/blocs/face_detection_state.dart';
import 'package:liveness/speakwords.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _cameraController.initialize();
        if (!mounted) return;
        context.read<CameraControllerCubit>().changeValue(_cameraController);
      } catch (e) {
        print('Error initializing camera: $e');
      }
    } else {
      print('Camera permission denied');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FaceDetectionCubit, FaceDetectionState>(
          listener: (context, state) {
            if (state is FaceDetectionLoadedState) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpeakWordsPage(
                    imageFile: state.file,
                  ),
                ),
              );
            } else if (state is FaceDetectionErrorState) {
              const sbar =
                  SnackBar(content: Text('Failed to capture image, Try again'));

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(sbar);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Page'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              CameraPreview(
                context.watch<CameraControllerCubit>().state!,
              ),
              Positioned(
                bottom: 30,
                left: MediaQuery.of(context).size.width * 0.25,
                child: ElevatedButton(
                  onPressed: () async {
                    final XFile photo = await context
                        .read<CameraControllerCubit>()
                        .state!
                        .takePicture();
                    context
                        .read<FaceDetectionCubit>()
                        .detectFace(file: photo);
                                    },
                  child: const Text('Take Picture'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
