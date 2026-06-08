const jwt = require('jsonwebtoken');
const { Session, Booking, ChatMessage, User } = require('../models');

module.exports = (io) => {
  // Authenticate socket via token in handshake
  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.query?.token;
      if (!token) return next(new Error('Authentication required'));
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId   = decoded.id;
      socket.userRole = decoded.role;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    // ── Session room ───────────────────────────────────────────────────────────

    socket.on('join_room', async ({ roomId }) => {
      try {
        socket.join(roomId);
        socket.data = { roomId };

        const session = await Session.findOne({ where: { roomId } });
        if (!session) return;

        const update = {};
        if (socket.userRole === 'client') update.clientJoined = true;
        if (socket.userRole === 'lawyer') update.lawyerJoined = true;

        await session.update(update);
        await session.reload();

        if (session.clientJoined && session.lawyerJoined && !session.startedAt) {
          await session.update({ startedAt: new Date(), status: 'active' });
          io.to(roomId).emit('session_started', { startedAt: session.startedAt });
        }

        io.to(roomId).emit('user_joined', { userId: socket.userId, role: socket.userRole });
      } catch (err) {
        console.error('[socket.join_room]', err.message);
      }
    });

    socket.on('timer_ended', async ({ roomId }) => {
      try {
        const session = await Session.findOne({ where: { roomId } });
        if (!session) return;

        const endedAt = new Date();
        await session.update({ endedAt, status: 'ended' });
        await Booking.update({ endedAt, status: 'completed' }, { where: { id: session.bookingId } });

        io.to(roomId).emit('room_closed', { endedAt });
      } catch (err) {
        console.error('[socket.timer_ended]', err.message);
      }
    });

    socket.on('disconnect', () => {
      const { roomId } = socket.data || {};
      if (roomId) {
        io.to(roomId).emit('user_left', { userId: socket.userId, role: socket.userRole });
      }
    });

    // ── Persistent chat ────────────────────────────────────────────────────────

    socket.on('chat:join', ({ bookingId }) => {
      socket.join(`chat_${bookingId}`);
    });

    socket.on('chat:send', async ({ bookingId, message }) => {
      try {
        if (!message?.trim()) return;

        const booking = await Booking.findByPk(bookingId);
        if (!booking) return;
        const isParty = booking.clientId === socket.userId || booking.lawyerId === socket.userId;
        if (!isParty) return;

        const sender = await User.findByPk(socket.userId, { attributes: ['id', 'name', 'avatar'] });

        const msg = await ChatMessage.create({
          bookingId,
          senderId:   socket.userId,
          senderRole: socket.userRole,
          message:    message.trim(),
        });

        io.to(`chat_${bookingId}`).emit('chat:message', {
          id:         msg.id,
          bookingId:  msg.bookingId,
          senderId:   msg.senderId,
          senderRole: msg.senderRole,
          message:    msg.message,
          createdAt:  msg.createdAt,
          sender:     { id: sender.id, name: sender.name, avatar: sender.avatar },
        });
      } catch (err) {
        console.error('[socket.chat:send]', err.message);
      }
    });
  });
};
