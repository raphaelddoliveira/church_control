import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

String? _getEmbedUrl(String url) {
  // YouTube
  final youtubeRegex = RegExp(
    r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)',
  );
  final youtubeMatch = youtubeRegex.firstMatch(url);
  if (youtubeMatch != null) {
    return 'https://www.youtube.com/embed/${youtubeMatch.group(1)}?autoplay=0';
  }

  // Spotify track
  final spotifyTrackRegex = RegExp(r'open\.spotify\.com\/track\/([a-zA-Z0-9]+)');
  final spotifyTrackMatch = spotifyTrackRegex.firstMatch(url);
  if (spotifyTrackMatch != null) {
    return 'https://open.spotify.com/embed/track/${spotifyTrackMatch.group(1)}?theme=0';
  }

  // Spotify playlist
  final spotifyPlaylistRegex = RegExp(r'open\.spotify\.com\/playlist\/([a-zA-Z0-9]+)');
  final spotifyPlaylistMatch = spotifyPlaylistRegex.firstMatch(url);
  if (spotifyPlaylistMatch != null) {
    return 'https://open.spotify.com/embed/playlist/${spotifyPlaylistMatch.group(1)}?theme=0';
  }

  // Spotify album
  final spotifyAlbumRegex = RegExp(r'open\.spotify\.com\/album\/([a-zA-Z0-9]+)');
  final spotifyAlbumMatch = spotifyAlbumRegex.firstMatch(url);
  if (spotifyAlbumMatch != null) {
    return 'https://open.spotify.com/embed/album/${spotifyAlbumMatch.group(1)}?theme=0';
  }

  return null;
}

Widget buildMusicPlayer(BuildContext context, String url) {
  final embedUrl = _getEmbedUrl(url);

  if (embedUrl == null) {
    // Link não é YouTube nem Spotify, abre externamente
    return InkWell(
      onTap: () => html.window.open(url, '_blank'),
      child: Container(
        padding: EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.music_note_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 24.0,
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Música do Devocional',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'Toque para ouvir',
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  // Determinar altura do player
  final bool isSpotify = embedUrl.contains('spotify.com');
  final double playerHeight = isSpotify ? 80.0 : 200.0;

  // Registrar view factory com ID único
  final viewType = 'music-player-${url.hashCode}';
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.borderRadius = '12px'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture'
        ..setAttribute('allowfullscreen', 'true')
        ..setAttribute('loading', 'lazy');
      return iframe;
    },
  );

  return Container(
    height: playerHeight,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: HtmlElementView(viewType: viewType),
    ),
  );
}
