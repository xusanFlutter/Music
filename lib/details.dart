import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:musics/common.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';

class Details extends StatefulWidget {
  const Details({Key? key, required this.songModel}) : super(key: key);
  final SongModel songModel;

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  @override
  void initState() {
    super.initState();

    if (_isPlaying == false) {
      playSong();
    } else {
      return;
    }
  }

  void playSong() {
    try {
      _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
            widget.songModel.uri.toString(),
          ),
        ),
      );
      _player.play();
      _isPlaying = true;
    } on Exception {
      log('Cannot parse Song');
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff370066).withOpacity(1),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: SizedBox(
          width: 300,
          height: 100,
          child: Marquee(
            style: const TextStyle(
              fontSize: 17,
            ),
            scrollAxis: Axis.horizontal,
            text: widget.songModel.displayNameWOExt +
                '      ' +
                widget.songModel.artist.toString(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
        backgroundColor: const Color(0xff370066).withOpacity(1),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/logo1.png',
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: _player.seek,
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _player.seekToPrevious();
                    HapticFeedback.lightImpact();
                  },
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (_isPlaying) {
                        _player.pause();
                      } else {
                        _player.play();
                      }
                      _isPlaying = !_isPlaying;
                    });
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    _player.seekToNext();
                    HapticFeedback.lightImpact();
                  },
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class Details extends StatefulWidget {
//   const Details({Key? key, required this.songModel}) : super(key: key);
//   final SongModel songModel;

//   @override
//   _DetailsState createState() => _DetailsState();
// }

// class _DetailsState extends State<Details> with WidgetsBindingObserver {
//   final _player = AudioPlayer();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addObserver(this);
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.black,
//     ));
//     _init();
//     _player.play();
//   }

//   Future<void> _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//     _player.playbackEventStream.listen((event) {},
//         onError: (Object e, StackTrace stackTrace) {
//       // ignore: avoid_print
//       print('A stream error occurred: $e');
//     });
//     try {
//       await _player.setAudioSource(
//         AudioSource.uri(
//           Uri.parse('${widget.songModel.uri}'),
//         ),
//       );
//     } catch (e) {
//       // ignore: avoid_print
//       print("Error loading audio source: $e");
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance?.removeObserver(this);

//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _player.stop();
//     }
//   }

//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           _player.positionStream,
//           _player.bufferedPositionStream,
//           _player.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.arrow_back_ios),
//         ),
//         title: SizedBox(
//           width: 300,
//           height: 100,
//           child: Marquee(
//             style: const TextStyle(
//               fontSize: 17,
//             ),
//             scrollAxis: Axis.horizontal,
//             text: widget.songModel.displayNameWOExt +
//                 '      ' +
//                 widget.songModel.artist.toString(),
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(
//               Icons.more_vert,
//             ),
//           ),
//         ],
//         backgroundColor: const Color(0xff370066).withOpacity(1),
//         elevation: 0,
//       ),
//       backgroundColor: const Color(0xff370066).withOpacity(1),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.asset(
//                 'assets/logo1.png',
//                 width: 300,
//                 height: 300,
//               ),
//             ),
//             const SizedBox(height: 30),
//             StreamBuilder<PositionData>(
//               stream: _positionDataStream,
//               builder: (context, snapshot) {
//                 final positionData = snapshot.data;
//                 return SeekBar(
//                   duration: positionData?.duration ?? Duration.zero,
//                   position: positionData?.position ?? Duration.zero,
//                   bufferedPosition:
//                       positionData?.bufferedPosition ?? Duration.zero,
//                   onChangeEnd: _player.seek,
//                 );
//               },
//             ),
//             ControlButtons(_player),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ControlButtons extends StatelessWidget {
//   final AudioPlayer player;

//   // ignore: use_key_in_widget_constructors
//   const ControlButtons(this.player);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             player.seekToPrevious();
//           },
//           icon: const Icon(
//             Icons.skip_previous,
//             color: Colors.white,
//             size: 40,
//           ),
//         ),
//         const SizedBox(width: 20),
//         StreamBuilder<PlayerState>(
//           stream: player.playerStateStream,
//           builder: (context, snapshot) {
//             final playerState = snapshot.data;
//             final processingState = playerState?.processingState;
//             final playing = playerState?.playing;
//             if (processingState == ProcessingState.loading ||
//                 processingState == ProcessingState.buffering) {
//               return Container(
//                 margin: const EdgeInsets.all(8.0),
//                 width: 64.0,
//                 height: 64.0,
//                 child: const CircularProgressIndicator(),
//               );
//             } else if (playing != true) {
//               return IconButton(
//                 icon: const Icon(
//                   Icons.play_arrow,
//                   color: Colors.white,
//                 ),
//                 iconSize: 64.0,
//                 onPressed: player.play,
//               );
//             } else if (processingState != ProcessingState.completed) {
//               return IconButton(
//                 icon: const Icon(
//                   Icons.pause,
//                   color: Colors.white,
//                 ),
//                 iconSize: 64.0,
//                 onPressed: player.pause,
//               );
//             } else {
//               return IconButton(
//                 icon: const Icon(
//                   Icons.replay,
//                   color: Colors.white,
//                 ),
//                 iconSize: 64.0,
//                 onPressed: () => player.seek(Duration.zero),
//               );
//             }
//           },
//         ),
//         const SizedBox(width: 20),
//         IconButton(
//           onPressed: () {
//             player.setLoopMode(LoopMode.all);
//             HapticFeedback.lightImpact();
//           },
//           icon: const Icon(
//             Icons.skip_next,
//             color: Colors.white,
//             size: 40,
//           ),
//         ),
//       ],
//     );
//   }
// }

