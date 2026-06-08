import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/debug_logger.dart';
import '../cubits/session_cubit.dart';
import '../cubits/session_state.dart';

class SessionScreen extends StatefulWidget {
  final int bookingId;
  final String otherPartyName;
  final String sessionType; // 'video' | 'audio' | 'text'
  final bool isClient;

  const SessionScreen({
    super.key,
    required this.bookingId,
    required this.otherPartyName,
    required this.sessionType,
    required this.isClient,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  EventsListener<RoomEvent>? _listener;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndJoin();
  }

  Future<void> _requestPermissionsAndJoin() async {
    // Request both and check results — join regardless (cubit handles partial grants)
    final statuses = await [Permission.camera, Permission.microphone].request();
    final camOk = statuses[Permission.camera]?.isGranted ?? false;
    final micOk = statuses[Permission.microphone]?.isGranted ?? false;
    DebugLogger.log('SessionScreen', 'permissions: camera=$camOk mic=$micOk');
    if (mounted) {
      context.read<SessionCubit>().join(widget.bookingId);
    }
  }

  @override
  void dispose() {
    _listener?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _confirmLeave(context);
          if (leave && context.mounted) {
            await context.read<SessionCubit>().leave();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is SessionConnected) {
              _listener?.dispose();
              _listener = state.room.createListener()
                ..on<ParticipantConnectedEvent>((_) => setState(() {}))
                ..on<ParticipantDisconnectedEvent>((_) {
                  final s = context.read<SessionCubit>().state;
                  if (s is SessionConnected && s.room.remoteParticipants.isEmpty) {
                    context.read<SessionCubit>().leave();
                  } else {
                    setState(() {});
                  }
                })
                ..on<TrackSubscribedEvent>((_) => setState(() {}))
                ..on<TrackUnsubscribedEvent>((_) => setState(() {}))
                ..on<TrackMutedEvent>((_) => setState(() {}))
                ..on<TrackUnmutedEvent>((_) => setState(() {}))
                ..on<RoomDisconnectedEvent>((_) {
                  if (mounted) context.read<SessionCubit>().leave();
                });
            }
            if (state is SessionEnded) {
              if (widget.isClient) {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.review,
                  arguments: {
                    'bookingId':  state.bookingId,
                    'lawyerName': widget.otherPartyName,
                  },
                );
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            if (state is SessionConnecting) return _buildConnecting();
            if (state is SessionFailed)     return _buildError(context, state.message);
            if (state is SessionConnected)  return _buildCall(context, state);
            return _buildConnecting();
          },
        ),
      ),
    );
  }

  // ── Connecting ─────────────────────────────────────────────────────────────

  Widget _buildConnecting() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      const SizedBox(height: 20),
      Text('Connecting to ${widget.otherPartyName}…',
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15)),
    ]));
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
          child: Text('Go Back', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      ]),
    ));
  }

  // ── Active call ────────────────────────────────────────────────────────────

  Widget _buildCall(BuildContext context, SessionConnected state) {
    final room = state.room;
    final remoteParticipant = room.remoteParticipants.values.firstOrNull;
    final localParticipant  = room.localParticipant;

    final remoteVideoTrack = _firstVideoTrack(remoteParticipant);
    final localVideoTrack  = _firstLocalVideoTrack(localParticipant);

    final isVideo = widget.sessionType != 'audio';

    return Stack(children: [
      // ── Remote video / waiting background ─────────────────────────────────
      Positioned.fill(
        child: remoteVideoTrack != null && isVideo
            ? VideoTrackRenderer(remoteVideoTrack,
                fit: VideoViewFit.cover)
            : _buildWaitingBackground(remoteParticipant),
      ),

      // ── Gradient overlay (top) ─────────────────────────────────────────────
      Positioned(
        top: 0, left: 0, right: 0, height: 140,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xCC000000), Colors.transparent],
            ),
          ),
        ),
      ),

      // ── Gradient overlay (bottom) ──────────────────────────────────────────
      Positioned(
        bottom: 0, left: 0, right: 0, height: 180,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [Color(0xDD000000), Colors.transparent],
            ),
          ),
        ),
      ),

      // ── Top bar ────────────────────────────────────────────────────────────
      Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.otherPartyName,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                Text(
                  remoteParticipant != null ? _formatDuration(state.secondsElapsed) : 'Waiting to join…',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                ),
              ])),
              // Connection quality indicator
              if (remoteParticipant != null)
                _ConnectionQuality(participant: remoteParticipant),
            ]),
          ),
        ),
      ),

      // ── Local preview (PiP) ───────────────────────────────────────────────
      if (isVideo)
        Positioned(
          right: 16, top: 120,
          child: _LocalPreview(
            track: localVideoTrack,
            isCameraEnabled: state.isCameraEnabled,
          ),
        ),

      // ── Controls ──────────────────────────────────────────────────────────
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlBtn(
                  icon: state.isMicEnabled ? Icons.mic : Icons.mic_off,
                  label: state.isMicEnabled ? 'Mute' : 'Unmute',
                  active: state.isMicEnabled,
                  onTap: () => context.read<SessionCubit>().toggleMic(),
                ),
                if (isVideo)
                  _ControlBtn(
                    icon: state.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                    label: state.isCameraEnabled ? 'Camera' : 'Camera off',
                    active: state.isCameraEnabled,
                    onTap: () => context.read<SessionCubit>().toggleCamera(),
                  ),
                _EndCallBtn(onTap: () async {
                  final leave = await _confirmLeave(context);
                  if (leave && context.mounted) {
                    context.read<SessionCubit>().leave();
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  VideoTrack? _firstVideoTrack(RemoteParticipant? p) {
    if (p == null) return null;
    for (final pub in p.videoTrackPublications) {
      if (pub.subscribed && pub.track != null) return pub.track as VideoTrack;
    }
    return null;
  }

  LocalVideoTrack? _firstLocalVideoTrack(LocalParticipant? p) {
    if (p == null) return null;
    for (final pub in p.videoTrackPublications) {
      if (pub.track != null) return pub.track as LocalVideoTrack;
    }
    return null;
  }

  Widget _buildWaitingBackground(RemoteParticipant? remote) {
    return Container(
      color: const Color(0xFF0D0D1A),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white12, shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Center(child: Text(
            widget.otherPartyName.isNotEmpty ? widget.otherPartyName[0].toUpperCase() : '?',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white70),
          )),
        ),
        const SizedBox(height: 16),
        Text(
          remote == null ? 'Waiting for ${widget.otherPartyName}…' : '${widget.otherPartyName} has no video',
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
        ),
      ])),
    );
  }

  Future<bool> _confirmLeave(BuildContext ctx) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('End Call', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to leave the session?',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text('End Call', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    return result ?? false;
  }
}

// ── Subwidgets ─────────────────────────────────────────────────────────────────

class _LocalPreview extends StatelessWidget {
  final LocalVideoTrack? track;
  final bool isCameraEnabled;
  const _LocalPreview({required this.track, required this.isCameraEnabled});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100, height: 140,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: track != null && isCameraEnabled
            ? VideoTrackRenderer(track!, fit: VideoViewFit.cover)
            : Center(child: Icon(Icons.videocam_off, color: Colors.white38, size: 28)),
      ),
    );
  }
}

class _ConnectionQuality extends StatelessWidget {
  final RemoteParticipant participant;
  const _ConnectionQuality({required this.participant});

  @override
  Widget build(BuildContext context) {
    final quality = participant.connectionQuality;
    final color = quality == ConnectionQuality.excellent
        ? Colors.greenAccent
        : quality == ConnectionQuality.good
            ? Colors.yellowAccent
            : Colors.redAccent;
    return Icon(Icons.signal_cellular_alt, color: color, size: 18);
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: active ? Colors.white24 : Colors.white12,
            shape: BoxShape.circle,
            border: Border.all(color: active ? Colors.white38 : Colors.white12),
          ),
          child: Icon(icon, color: active ? Colors.white : Colors.white54, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
      ]),
    );
  }
}

class _EndCallBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _EndCallBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          child: const Icon(Icons.call_end, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text('End', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
      ]),
    );
  }
}
