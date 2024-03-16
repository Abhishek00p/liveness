import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liveness/blocs/cameraController_cubit.dart';
import 'package:liveness/blocs/isListening_cubit.dart';
import 'package:liveness/blocs/spoken_number_cubit.dart';
import 'package:liveness/blocs/user_location_cubit.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeakWordsPage extends StatefulWidget {
  const SpeakWordsPage({required this.imageFile, super.key});

  final XFile imageFile;

  @override
  State<SpeakWordsPage> createState() => _SpeakWordsPageState();
}

class _SpeakWordsPageState extends State<SpeakWordsPage> {
  @override
  void initState() {
    super.initState();
    // context.read<CameraControllerCubit>().state?.pausePreview();
    context.read<IsAudioListening>().changeValue(false);
    context.read<UserLocation>().changeValue('');
    context.read<SpokenNumber>().changeValue('');

    try {
      getPosition();
    } catch (e) {
      debugPrint('error occured while fetching location');
    }
  }

  getPosition() async {
    await _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final sbar = SnackBar(content: Text('Location is disabled'));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(sbar);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        final sbar = SnackBar(content: Text('Location permission is denied'));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(sbar);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      final sbar = SnackBar(
          content: Text('Kindly enable location permission from setting'));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(sbar);
      return;
    }
    final _pos = await Geolocator.getCurrentPosition();
    context
        .read<UserLocation>()
        .changeValue('GPS ${_pos.latitude},${_pos.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speak Number to Test Liveness'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.9,
              color: const Color.fromARGB(255, 236, 160, 160),
              child: Image.file(
                File(widget.imageFile.path),
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 10.0),
            Text(context.watch<UserLocation>().state),
            SizedBox(height: 10.0),
            BlocBuilder<SpokenNumber, String>(
              builder: (context, state) {
                return Row(
                  children: [
                    Text(state),
                    SizedBox(
                      width: 15,
                    ),
                    state.isNotEmpty
                        ? Text(
                            'PASSED',
                            style: TextStyle(color: Colors.green),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
            SizedBox(height: 10.0),
            Text('speak a number within 5 sec after tapped on Start test'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: context.read<IsAudioListening>().state
                  ? () {}
                  : () async {
                      startListening();
                    },
              child: BlocBuilder<IsAudioListening, bool>(
                builder: (context, state) {
                  return Text(state ? 'listening...' : 'Start Audio Test');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  startListening() async {
    final _speech = SpeechToText();
    if (await _speech.initialize()) {
      debugPrint('listening started');
      context.read<IsAudioListening>().changeValue(true);
      _speech.listen(
        listenOptions: SpeechListenOptions(
            partialResults: false,
            cancelOnError: true,
            listenMode: ListenMode.confirmation),
        listenFor: const Duration(seconds: 5),

        // pauseFor: Duration.zero,
        onResult: (result) => _processResult(result),
      );
      await Future.delayed(
          Duration(
            seconds: 5,
          ), () {
        context.read<IsAudioListening>().changeValue(false);
      });
    } else {
      debugPrint('failed init of _speech');
    }
  }

  _processResult(SpeechRecognitionResult result) {
    debugPrint('audio data rcvd');
    debugPrint('recognized word : ${result.recognizedWords}');
    // context.read<IsAudioListening>().changeValue(false);

    if (result.recognizedWords.isEmpty) {
      final sbar = SnackBar(content: Text('Failed to recognize spoken number'));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(sbar);
      debugPrint('got u');
      context.read<IsAudioListening>().changeValue(false);
      return;
    }

    RegExp regExp = RegExp(r'\b\d{1,3}\b');
    Iterable<Match> matches = regExp.allMatches(result.recognizedWords);
    List<String?> numbers = matches.map((match) => match.group(0)).toList();
    if (numbers.isNotEmpty) {
      debugPrint('Spoken numbers: $numbers');
      context
          .read<SpokenNumber>()
          .changeValue('you spoke : ${numbers.firstOrNull ?? 'not detected'}');
    } else {
      final sbar =
          SnackBar(content: Text('Please speak a number less then 3 digit'));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(sbar);
    }

    context.read<IsAudioListening>().changeValue(false);
  }
}