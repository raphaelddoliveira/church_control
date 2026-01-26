import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

String? _getYoutubeVideoId(String url) {
  final youtubeRegex = RegExp(
    r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)',
  );
  final match = youtubeRegex.firstMatch(url);
  return match?.group(1);
}

bool _isSpotifyUrl(String url) {
  return url.contains('open.spotify.com');
}

String? _getSpotifyEmbedUrl(String url) {
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
  final youtubeVideoId = _getYoutubeVideoId(url);
  final spotifyEmbedUrl = _getSpotifyEmbedUrl(url);

  // YouTube video - use WebView
  if (youtubeVideoId != null) {
    return _YouTubePlayerWidget(videoId: youtubeVideoId);
  }

  // Spotify - use WebView
  if (spotifyEmbedUrl != null) {
    return _SpotifyPlayerWidget(embedUrl: spotifyEmbedUrl);
  }

  // Link não é YouTube nem Spotify, abre externamente
  return InkWell(
    onTap: () => launchURL(url),
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

class _YouTubePlayerWidget extends StatefulWidget {
  final String videoId;

  const _YouTubePlayerWidget({required this.videoId});

  @override
  State<_YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<_YouTubePlayerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color(0xFF1A1A1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Permite apenas URLs do YouTube
            if (request.url.contains('youtube.com') ||
                request.url.contains('youtu.be') ||
                request.url.contains('google.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(
        'https://www.youtube.com/embed/${widget.videoId}?autoplay=0&rel=0&modestbranding=1&playsinline=1&enablejsapi=1&origin=https://www.youtube.com',
      ));
  }

  void _openInBrowser() {
    launchURL('https://www.youtube.com/watch?v=${widget.videoId}');
  }

  @override
  Widget build(BuildContext context) {
    // Se houver erro, mostra botão para abrir externamente
    if (_hasError) {
      return Container(
        height: 200.0,
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: InkWell(
          onTap: _openInBrowser,
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: Color(0xFFFF0000),
                size: 48.0,
              ),
              SizedBox(height: 12.0),
              Text(
                'Toque para assistir no YouTube',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                'O vídeo será aberto externamente',
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            // Botão de abrir externamente no canto superior direito
            Positioned(
              top: 8.0,
              right: 8.0,
              child: InkWell(
                onTap: _openInBrowser,
                child: Container(
                  padding: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotifyPlayerWidget extends StatefulWidget {
  final String embedUrl;

  const _SpotifyPlayerWidget({required this.embedUrl});

  @override
  State<_SpotifyPlayerWidget> createState() => _SpotifyPlayerWidgetState();
}

class _SpotifyPlayerWidgetState extends State<_SpotifyPlayerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color(0xFF1A1A1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
