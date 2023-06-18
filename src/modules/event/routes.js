import express from 'express'
import eventController from './controller.js';

export const eventRouter = express.Router();

eventRouter.get('/', eventController.getEvents)
eventRouter.get('/past', eventController.getPastEvents)
eventRouter.get('/stats', eventController.getEventStats)
eventRouter.get('/clientStats', eventController.getClientEventStats)
eventRouter.get('/allUpcoming', eventController.getAllUpcomingEvents)
eventRouter.post('/register', eventController.register)
eventRouter.post('/delete', eventController.deleteEvent)