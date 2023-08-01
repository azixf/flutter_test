import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: kDebugMode,
        theme: ThemeData(
          colorSchemeSeed: Colors.blueAccent,
          useMaterial3: true,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter Test'),
            ),
            body: const AppBody()));
  }
}

class AppBody extends StatefulWidget {
  const AppBody({super.key});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  late final List<DownloadController> _downloadControllers;

  void _onOpenDownload(int index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('On open app #${index + 1}'),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      duration: const Duration(milliseconds: 600),
    ));
  }

  @override
  void initState() {
    super.initState();
    _downloadControllers = List<DownloadController>.generate(
        20,
        (index) => SimulatedDownloadController(onOpenDownload: () {
              _onOpenDownload(index);
            }));
  }

  @override
  void dispose() {
    for (final controll in _downloadControllers) {
      controll.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: _buildListItem,
        separatorBuilder: (_, __) => const Divider(),
        itemCount: _downloadControllers.length);
  }

  Widget _buildListItem(BuildContext context, int index) {
    final DownloadController downloadController = _downloadControllers[index];
    return ListTile(
        leading: const FlutterLogo(),
        title: Text(
          'App ${index + 1}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          'This is a subtitle #${index + 1}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: SizedBox(
          width: 96,
          child: AnimatedBuilder(
            animation: downloadController,
            builder: (context, child) => DownloadButton(
              status: downloadController.status,
              downloadProgress: downloadController.progress,
              onCancel: downloadController.stopDownload,
              onDownload: downloadController.startDownload,
              onOpen: downloadController.openDownload,
            ),
          ),
        ));
  }
}

abstract class DownloadController implements ChangeNotifier {
  DownloadStatus get status;
  double get progress;

  void startDownload();
  void stopDownload();
  void openDownload();
}

class SimulatedDownloadController extends DownloadController
    with ChangeNotifier {
  SimulatedDownloadController(
      {DownloadStatus status = DownloadStatus.notDownloaded,
      double progress = 0.0,
      required VoidCallback onOpenDownload})
      : _progress = progress,
        _downloadStatus = status,
        _onOpenDownload = onOpenDownload;

  DownloadStatus _downloadStatus;
  @override
  DownloadStatus get status => _downloadStatus;

  double _progress;
  @override
  double get progress => _progress;

  final VoidCallback _onOpenDownload;

  bool _isDownloading = false;

  @override
  void startDownload() {
    if (_downloadStatus == DownloadStatus.notDownloaded) {
      _doSimulaterDownload();
    }
  }

  @override
  void stopDownload() {
    if (_isDownloading) {
      _isDownloading = false;
      _downloadStatus = DownloadStatus.notDownloaded;
      _progress = 0.0;
      notifyListeners();
    }
  }

  @override
  void openDownload() {
    if (_downloadStatus == DownloadStatus.downloaded) {
      _onOpenDownload();
    }
  }

  Future<void> _doSimulaterDownload() async {
    _isDownloading = true;
    _downloadStatus = DownloadStatus.fetchingDownload;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (!_isDownloading) return;

    _downloadStatus = DownloadStatus.downloading;
    notifyListeners();

    const progressList = [0.0, 0.15, 0.45, 0.85, 1.0];
    for (final stop in progressList) {
      await Future.delayed(const Duration(seconds: 1));

      if (!_isDownloading) return;

      _progress = stop;
      notifyListeners();
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!_isDownloading) return;

    _downloadStatus = DownloadStatus.downloaded;
    _isDownloading = false;
    notifyListeners();
  }
}

enum DownloadStatus { notDownloaded, fetchingDownload, downloading, downloaded }

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton(
      {super.key,
      required this.status,
      this.transitionDuration = const Duration(milliseconds: 500),
      this.downloadProgress = 0.5,
      required this.onCancel,
      required this.onDownload,
      required this.onOpen});

  final DownloadStatus status;
  final Duration transitionDuration;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onOpen;
  final VoidCallback onCancel;

  bool get _isDownloading => status == DownloadStatus.downloading;
  bool get _isFetching => status == DownloadStatus.fetchingDownload;
  bool get _isDownloaded => status == DownloadStatus.downloaded;

  @override
  Widget build(BuildContext context) {
    void _onPressed() {
      switch (status) {
        case DownloadStatus.notDownloaded:
          onDownload();
          break;
        case DownloadStatus.fetchingDownload:
          break;
        case DownloadStatus.downloading:
          onCancel();
          break;
        case DownloadStatus.downloaded:
          onOpen();
          break;
      }
    }

    return GestureDetector(
      onTap: _onPressed,
      child: Stack(children: [
        ButtonShapeWidget(
            isDownloading: _isDownloading,
            isFetching: _isFetching,
            isDownloaded: _isDownloaded,
            transitionDuration: transitionDuration),
        Positioned.fill(
            child: AnimatedOpacity(
                duration: transitionDuration,
                opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
                curve: Curves.ease,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProgressIndicatorWidget(
                        progress: downloadProgress,
                        isDownloading: _isDownloading,
                        isFetching: _isFetching),
                    if (_isDownloading)
                      const Icon(
                        Icons.stop,
                        size: 14.0,
                        color: CupertinoColors.activeBlue,
                      )
                  ],
                )))
      ]),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget(
      {super.key,
      required this.isDownloading,
      required this.isFetching,
      required this.isDownloaded,
      required this.transitionDuration});

  final bool isDownloading;
  final bool isFetching;
  final bool isDownloaded;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    var shape = const ShapeDecoration(
        shape: StadiumBorder(), color: CupertinoColors.lightBackgroundGray);

    if (isDownloading || isFetching) {
      shape = ShapeDecoration(
          shape: const CircleBorder(), color: Colors.white.withOpacity(0.0));
    }
    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedOpacity(
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          duration: transitionDuration,
          curve: Curves.ease,
          child: Text(
            isDownloaded ? 'OPEN' : 'GET',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
          ),
        ),
      ),
    );
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget(
      {super.key,
      required this.progress,
      required this.isDownloading,
      required this.isFetching});

  final double progress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 200),
          builder: (context, prog, child) {
            return CircularProgressIndicator(
              backgroundColor: isDownloading
                  ? CupertinoColors.lightBackgroundGray
                  : Colors.white.withOpacity(0.0),
              valueColor: AlwaysStoppedAnimation(isFetching
                  ? CupertinoColors.lightBackgroundGray
                  : CupertinoColors.activeBlue),
              strokeWidth: 2,
              value: isFetching ? null : prog,
            );
          }),
    );
  }
}
