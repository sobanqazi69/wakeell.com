require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const connectDB = require('./src/config/db');
const errorHandler = require('./src/middleware/errorHandler');

const authRoutes = require('./src/routes/auth.routes');
const lawyerRoutes = require('./src/routes/lawyer.routes');
const bookingRoutes = require('./src/routes/booking.routes');
const sessionRoutes = require('./src/routes/session.routes');
const reviewRoutes = require('./src/routes/review.routes');
const adminRoutes = require('./src/routes/admin.routes');

const socketHandler = require('./src/socket');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/lawyers', lawyerRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/sessions', sessionRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/admin', adminRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use(errorHandler);

socketHandler(io);

const PORT = process.env.PORT || 3000;

connectDB().then(() => {
  server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
});
