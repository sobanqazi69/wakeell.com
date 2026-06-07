const { Session, Booking } = require('../models');

module.exports = (io) => {
  io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}`);

    socket.on('join_room', async ({ roomId, userId, role }) => {
      try {
        socket.join(roomId);
        socket.data = { roomId, userId, role };

        const session = await Session.findOne({ where: { roomId } });
        if (!session) return;

        const update = {};
        if (role === 'client') update.clientJoined = true;
        if (role === 'lawyer') update.lawyerJoined = true;

        await session.update(update);
        await session.reload();

        if (session.clientJoined && session.lawyerJoined && !session.startedAt) {
          await session.update({ startedAt: new Date(), status: 'active' });
          io.to(roomId).emit('session_started', { startedAt: session.startedAt });
        }

        io.to(roomId).emit('user_joined', { userId, role });
      } catch (err) {
        console.error('[socket.join_room]', err);
      }
    });

    socket.on('send_message', ({ roomId, message, senderId, senderName }) => {
      io.to(roomId).emit('receive_message', {
        message,
        senderId,
        senderName,
        timestamp: new Date(),
      });
    });

    socket.on('timer_ended', async ({ roomId }) => {
      try {
        const session = await Session.findOne({ where: { roomId } });
        if (!session) return;

        const endedAt = new Date();
        await session.update({ endedAt, status: 'ended' });
        await Booking.update({ endedAt }, { where: { id: session.bookingId } });

        io.to(roomId).emit('room_closed', { endedAt });
      } catch (err) {
        console.error('[socket.timer_ended]', err);
      }
    });

    socket.on('disconnect', () => {
      const { roomId, userId, role } = socket.data || {};
      if (roomId) {
        io.to(roomId).emit('user_left', { userId, role });
      }
    });
  });
};
