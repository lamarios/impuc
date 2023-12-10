import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invidious/comments/views/components/comments_container.dart';
import 'package:invidious/player/states/player.dart';
import 'package:invidious/videos/models/video.dart';
import 'package:invidious/videos/views/components/add_to_queue_button.dart';
import 'package:invidious/videos/views/components/play_button.dart';
import 'package:invidious/videos/views/components/recommended_videos.dart';

import '../../../globals.dart';
import '../../../settings/states/settings.dart';
import '../../states/video.dart';
import 'info.dart';
import 'video_thumbnail.dart';

class VideoInnerView extends StatelessWidget {
  final Video video;
  final int selectedIndex;
  bool? playNow;
  final VideoState videoController;

  VideoInnerView({super.key, required this.video, required this.selectedIndex, this.playNow, required this.videoController});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations locals = AppLocalizations.of(context)!;
    var textTheme = Theme.of(context).textTheme;
    var cubit = context.read<VideoCubit>();
    var settings = context.read<SettingsCubit>();
    String? currentlyPlayingVideoId = context.select((PlayerCubit player) => player.state.currentlyPlaying?.videoId);
    final bool restart = currentlyPlayingVideoId == video.videoId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoThumbnailView(
          videoId: video.videoId,
          thumbnailUrl: video.deArrowThumbnailUrl ?? video.getBestThumbnail()?.url ?? '',
          child: Stack(
            alignment: Alignment.center,
            children: [
              PlayButton(
                icon: restart ? Icons.refresh : null,
                onPressed: restart ? cubit.restartVideo : cubit.playVideo,
              ),
              Positioned(
                  right: 5,
                  bottom: 3,
                  child: AddToQueueButton(
                    videos: [video],
                  ))
            ],
          ),
        ),
        if (!settings.state.distractionFreeMode)
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (previous, current) => previous.playRecommendedNext != current.playRecommendedNext,
            builder: (context, settingsState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 25, child: Checkbox(value: settingsState.playRecommendedNext, onChanged: cubit.togglePlayRecommendedNext, visualDensity: VisualDensity.compact)),
                  InkWell(
                      onTap: () => cubit.togglePlayRecommendedNext(!settingsState.playRecommendedNext),
                      child: Text(
                        locals.addRecommendedToQueue,
                        style: textTheme.bodySmall,
                      ))
                ],
              );
            }
          ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: ListView(
            controller: cubit.scrollController,
            children: [
              AnimatedSwitcher(
                  duration: animationDuration,
                  child: <Widget>[
                    VideoInfo(
                      video: video,
                      dislikes: videoController.dislikes,
                    ),
                    CommentsContainer(
                      video: video,
                    ),
                    RecommendedVideos(video: video)
                  ][selectedIndex])
            ],
          ),
        )),
      ],
    );
  }
}
