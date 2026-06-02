const Session = require('../models/Session');
const Booking = require('../models/Booking');

module.exports = (io) => {
  io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}`);

    socket.on('join_room', async ({ roomId, userId, role }) => {
      socket.join(roomId);
      socket.data = { roomId, userId, role };

      const session = await Session.findOne({ roomId });
      if (!session) return;

      if (role === 'client') session.clientJoined = true;
      if (role === 'lawyer') session.lawyerJoined = true;

      if (session.clientJoined && session.lawyerJoined && !session.startedAt) {
        session.startedAt = new Date();
        session.status = 'active';
        io.to(roomId).emit('session_started', { startedAt: session.startedAt });
      }

      await session.save();
      io.to(roomId).emit('user_joined', { userId, role });
    });

    socket.on('send_message', ({ roomId, message, senderId, senderName }) => {
      io.to(roomId).emit('receive_message', { message, senderId, senderName, timestamp: new Date() });
    });

    socket.on('timer_ended', async ({ roomId }) => {
      const session = await Session.findOne({ roomId });
      if (!session) return;
      session.endedAt = new Date();
      session.status = 'ended';
      await session.save();
      await Booking.findByIdAndUpdate(session.booking, { endedAt: session.endedAt });
      io.to(roomId).emit('room_closed', { endedAt: session.endedAt });
    });

    socket.on('disconnect', () => {
      const { roomId, userId, role } = socket.data || {};
      if (roomId) {
        io.to(roomId).emit('user_left', { userId, role });
      }
    });
  });
};
