import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:stash/core/theme/app_theme.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _YoutubeEmbed(),
            const SizedBox(height: 24),
            Text(
              'Step-by-Step Guide',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _StepCard(
              title: '1. Add accounts',
              body:
                  'Go to the Accounts tab and add your bank accounts, cash, or savings. Each account has an optional initial balance.',
            ),
            _StepCard(
              title: '2. Record transactions',
              body:
                  'Use the Add tab to log deposits, expenses, or transfers. For expenses, choose a category. For transfers, select from and to accounts.',
            ),
            _StepCard(
              title: '3. Set budgets',
              body:
                  'In the Budget tab, set a monthly budget for each category. You\'ll see how much you\'ve spent vs your budget.',
            ),
            _StepCard(
              title: '4. View statistics',
              body:
                  'The Statistics tab shows monthly deposits, expenses, net balance, and charts for spending by category and trends over time.',
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to App'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All data is stored on your device. No account or internet required.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _YoutubeEmbed extends StatefulWidget {
  const _YoutubeEmbed();

  @override
  State<_YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<_YoutubeEmbed> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/tutorial.mp4',
      );

      final bundle = DefaultAssetBundle.of(context);
      await _videoController.initialize();
      final vttString = await bundle.loadString('assets/tutorial.vtt');

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        subtitle: Subtitles(_parseVtt(vttString)),
        subtitleBuilder: (context, subtitle) => subtitle.isNotEmpty
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink(),
      );

      setState(() {});
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  List<Subtitle> _parseVtt(String vtt) {
    final subtitles = <Subtitle>[];
    final lines = vtt.replaceAll('\r\n', '\n').split('\n');
    int index = 0;
    int i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.isEmpty ||
          line == 'WEBVTT' ||
          line.startsWith('NOTE') ||
          RegExp(r'^\d+$').hasMatch(line)) {
        i++;
        continue;
      }

      if (line.contains('-->')) {
        final parts = line.split('-->');
        final start = _parseVttTime(parts[0].trim());
        final end = _parseVttTime(parts[1].trim().split(' ')[0]);

        final textLines = <String>[];
        i++;
        while (i < lines.length && lines[i].trim().isNotEmpty) {
          final cleaned =
              lines[i].trim().replaceAll(RegExp(r'<[^>]+>'), '');
          if (cleaned.isNotEmpty) textLines.add(cleaned);
          i++;
        }

        if (textLines.isNotEmpty) {
          subtitles.add(Subtitle(
            index: index++,
            start: start,
            end: end,
            text: textLines.join('\n'),
          ));
        }
        continue;
      }

      i++;
    }

    return subtitles;
  }

  Duration _parseVttTime(String time) {
    final parts = time.split(':');
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secParts = parts[2].split('.');
      final seconds = int.parse(secParts[0]);
      final millis =
          int.parse(secParts[1].padRight(3, '0').substring(0, 3));
      return Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: millis);
    } else {
      final minutes = int.parse(parts[0]);
      final secParts = parts[1].split('.');
      final seconds = int.parse(secParts[0]);
      final millis =
          int.parse(secParts[1].padRight(3, '0').substring(0, 3));
      return Duration(
          minutes: minutes, seconds: seconds, milliseconds: millis);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: const Center(
            child: Text(
              'Could not load video.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 9 / 16,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}